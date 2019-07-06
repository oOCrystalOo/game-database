class SearchBrowseController < ApplicationController
  def search
    if params[:search].nil? || params[:search].length == 0
      return not_found()
    end
    
    term = params[:search]
    @games = JSON.parse(call_api("games", "fields name, id, cover; search \"#{term}\"; limit 50;"))
    @games.each do |game|
       game['cover_url'] = get_images_by_id(game['cover'], 'covers')[0]['url']
    end
  end
end
