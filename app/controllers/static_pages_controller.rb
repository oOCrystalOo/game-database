class StaticPagesController < ApplicationController
  def index
  end
  
  def games
    get_top_10()
  end
  
  def game
    game_id = params[:id]
    if game_id.blank?
      return not_found()
    end
    request = "fields *; where id=#{game_id};"
    response = call_api('games', request)
    @game = JSON.parse(response)[0]
    # Only needs to check for a status because it will return the game object without status otherwise
    if @game['status']
      return not_found()
    end
    
    @game['genres_names'] = get_genres(@game['genres'])
    
    cover_url = get_cover(@game['cover'])
    @game['cover_url'] = cover_url
    puts @platform
  end
  
  def get_top_10
    request = 'fields name, id, cover; where popularity >= 80 & aggregated_rating >= 80; sort aggregated_rating desc;'
    response = call_api('games', request)
    @data = JSON.parse(response)
    
    # Get the game covers
    @data.each do |game|
      cover_url = get_cover(game['cover'])
      game['cover_url'] = cover_url
    end
  end
  
  def not_found
    render plain: 'Game not found', status: :not_found
  end
  
  private
  def get_genres(genre_array)
    ids = genre_array.join(',')
    request = "fields name; where id = (#{ids});"
    return call_api('genres', request)
  end
  
  def get_cover(cover_id)
    request = "fields url; where id=#{cover_id};"
    response = call_api('covers', request)
    cover = JSON.parse(response)[0]
    if !cover['status']
      # Replace t_thumb with t_1080p for high quality image
      return cover['url'].sub! 't_thumb', 't_1080p'
    else
      return ''
    end
  end
end
