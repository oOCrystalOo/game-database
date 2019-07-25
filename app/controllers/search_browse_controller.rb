class SearchBrowseController < ApplicationController
  def search
    if params[:search].nil? || params[:search].length == 0
      return not_found()
    end
    
    term = params[:search]
    @games = get_games(term, 0)
  end
  
  def get_games (term, offset)
    request = "fields name, id, cover; search \"#{term}\"; limit 50; offset #{offset};"    
    games = JSON.parse(call_api("games", request))
    games.each do |game|
        if !game['cover'].nil?
          game['cover_url'] = get_images_by_id(game['cover'], 'covers')[0]['url']
        else
          game['cover_url'] = ActionController::Base.helpers.image_path('image_placeholder.png')
        end
    end
    
    if games.length > 0
      if !games[0]['status'].nil? 
        if games[0]['status'] == 400
          return Array.new()
        end
      end
    else 
      return games
    end
    
    # Get more, until end is reached
    if games.length == 50
      results = get_games(term, offset + 50)
      results.each do |game|
        games << game
      end
      return games
    else
      return games
    end
  end
  
  def browse 
    # Get items to put in sidebar
    @platforms = get_platforms()
    @genres = get_browse_cat('genres', 0, true)
    @themes = get_browse_cat('themes', 0, true)
  end
  
  def browse_games    
    theme = !params['theme'].nil? && params['theme'].length > 0 ? "themes = (#{params['theme']})" : ""
    platform = !params['platform'].nil? && params['platform'].length > 0 ? "platforms = (#{params['platform']})" : ""
    genre = !params['genre'].nil? && params['genre'].length > 0 ? "genres = (#{params['genre']})" : ""
    offset = params['offset']
    
    query = [theme, platform, genre].reject { |c| c.empty? }
    query_string = query.join(" & ")
    
    if query_string.length == 0
      return not_found()
    end
    
    results = JSON.parse(call_api('games', "fields *; limit 50; sort ratings desc; where #{query_string}; offset #{offset};"))
    results.each do |result|
        if !result['cover'].nil?
          result['cover_url'] = get_images_by_id(result['cover'], 'covers')[0]['url']
        else
          result['cover_url'] = ActionController::Base.helpers.image_path('image_placeholder.png')
        end
    end
    
    render json: results
  end
  
  def get_platforms
    results = JSON.parse(call_api('platforms', "fields *; limit 50; sort name asc; where generation = 8;"))
    # Add PC to list
    results << JSON.parse(call_api('platforms', 'fields *; search "microsoft windows";'))[0]
    
    return results
  end
  
  def get_browse_cat (type, offset, get_all)
    browse_results = JSON.parse(call_api(type, "fields *; limit 50; sort name asc; offset #{offset};"))
    if browse_results.length == 50 && get_all
      results = get_browse_cat(type, offset + 50, get_all)
      results.each do |result|
          browse_results << result
      end
      return browse_results
    end
    return browse_results
  end
end
