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
    @platforms = get_browse_cat('platforms', 0, true)
    @genres = get_browse_cat('genres', 0, true)
  end
  
  def browse_games
    if browse_params.nil? || browse_params.length == 0
      return not_found()
    end
    
    puts browse_params.inspect
    
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
  
  private
  def browse_params
    params.require(:browse).permit(:theme, :platform)
  end
end
