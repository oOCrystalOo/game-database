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
    
    if !@game['genres'].nil?
      @game['genres_names'] = get_names_from_ids(@game['genres'], 'genres')
    end
    if !@game['game_modes'].nil?
      @game['game_modes_values'] = get_names_from_ids(@game['game_modes'], 'game_modes')
    end
    if !@game['platforms'].nil?
      @game['platforms_names'] = get_names_from_ids(@game['platforms'], 'platforms')
    end
    if !@game['themes'].nil?
      @game['themes_names'] = get_names_from_ids(@game['themes'], 'themes')
    end
    if !@game['age_ratings'].nil?
      @game['age_rating_value'] = get_age_rating(@game['age_ratings'])
    end
    if !@game['cover'].nil?
      @game['cover_url'] = get_images_by_id(@game['cover'], 'covers')[0]['url']
    else
      @game['cover_url'] = ActionController::Base.helpers.image_path('image_placeholder.png')
    end
    if !@game['screenshots'].nil?
      @game['screenshots_urls'] = get_images_by_id(@game['screenshots'], 'screenshots')
    end
    if !@game['videos'].nil?
      @game['game_videos_urls'] = get_game_videos(@game['videos'])
    end
    if !@game['version_parent'].nil?
      @game['version_parent_info'] = get_names_from_ids(@game['version_parent'], 'games')[0]
    end
  end
  
  def get_top_10
    request = 'fields name, id, cover; where popularity >= 80 & aggregated_rating >= 80; sort aggregated_rating desc;'
    response = call_api('games', request)
    @data = JSON.parse(response)
    
    # Get the game covers
    @data.each do |game|
      game['cover_url'] = get_images_by_id(game['cover'], 'covers')[0]['url']
    end
  end
    
  private
  def get_names_from_ids (array, endpoint)
    if !array.kind_of?(Array)
      array = [ array ]
    end
    ids = array.join(',')
    request = "fields name; where id = (#{ids});"
    return JSON.parse(call_api(endpoint, request))
  end
  
  def get_game_videos(array)
    if !array.kind_of?(Array)
      array = [ array ]
    end
    ids = array.join(',')
    request = "fields video_id; where id = (#{ids});"
    return JSON.parse(call_api('game_videos', request))
  end
  
  def get_age_rating(ages_array)
    if ages_array.kind_of?(Array)
      ages_array = [ ages_array ]
    end
    
    ids = ages_array.join(',')
    request = "fields *; where id = (#{ids});"
    ratings = JSON.parse(call_api('age_ratings', request))
    
    category_dictionary = {
      1 => 'ESRB',
      2 => 'PEGI'
    }
    
    ratings_dictionary =  {
      1   => '3',
      2   => '7',
      3   => '12',
      4   => '16',
      5   => '18',
      6   => 'RP',
      7   => 'EC',
      8   => 'E',
      9   => 'E10',
      10  => 'T',
      11  => 'M',
      12  => 'AO'
    }
    
    ratings.each do |rating_hash|
      rating_hash['category_name'] = category_dictionary[rating_hash['category']]
      rating_hash['rating_name'] = ratings_dictionary[rating_hash['rating']]
    end
    
    return ratings
  end
end
