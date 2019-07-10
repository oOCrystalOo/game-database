class SearchBrowseController < ApplicationController
  def search
    if params[:search].nil? || params[:search].length == 0
      return not_found()
    end
    
    term = params[:search]
    @games = get_games(term, 0)
    puts "#{@games.length} games found"
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
    puts params.inspect
    # If it has parameters, get the games searched
    
    # If not, display all the items to refine search
    @platforms = JSON.parse(call_api('platforms', "fields *;"))
    @genres = JSON.parse(call_api('genres', 'fields *;'))
    @franchises = JSON.parse(call_api('franchises', 'fields *;'))
  end
end
