class StaticPagesController < ApplicationController
  def index
    
  end
  
  def games
    require 'net/http'
    offset = 0
    # the number of games to get
    num = 10
    game_ids = Array.new
    
    # while the number of game ids in the array is less than #{num}, get more top reviews
    while game_ids.length < num do
      uri = URI('http://www.gamespot.com/api/reviews/')
      params = {
        :api_key  => ENV['GAMESPOT_API_KEY'],
        :format   => 'json',
        :sort     => 'score:desc',
        :limit    => num + 5,
        :offset   => offset
      }
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)
      if response.code == "301"
        response = Net::HTTP.get_response(URI.parse(response.header['location']))
      end
      data = JSON.parse(response.body)['results']
      
      # loop through each review and get the game id
      data.each do |game|
        game_id = game['game']['id'].to_i
        game_ids.push(game_id)
      end
      
      # remove duplicates and get first #{num}
      game_ids = game_ids.uniq[0, num]
      
      # increase the offset if needed, and run the loop again with the new offset
      if game_ids.length < num
        offset = offset + num + 5
      end
    end
    
    # get game data from the #{num} ids
    @data = Array.new
    if game_ids.length == num
      game_ids.each do |id|
        game_data = get_game_data(id, false)
        @data.push(game_data)
      end
    end
  end
  
  def game
    id = params[:id]
    if id
      @game = get_game_data(id, true)
    end
    if @game.blank?
      render plain: 'Game not found', status: :not_found
    end
  end
  
  # Get platforms, publishers, etc available for search
  def search 
    require 'net/http'
    
    # Get Platforms
    platforms_total = 0
    platforms_offset = 0
    @platforms_data = Array.new()
    loop do
      response_body = get_giantbomb_api('platforms', platforms_offset)
      platforms_total = response_body['number_of_total_results']
      results = response_body['results']
      platforms_offset = platforms_offset + results.length
      results.each do |result|
        @platforms_data << result
      end
      if @platforms_data.length >= platforms_total
        break
      end
    end
    
    # Get Genres
    genres_total = 0
    genres_offset = 0
    @genres_data = Array.new()
    loop do
      response_body = get_giantbomb_api('genres', genres_offset)
      genres_total = response_body['number_of_total_results']
      results = response_body['results']
      genres_offset = genres_offset + results.length
      results.each do |result|
        @genres_data << result
      end
      if @genres_data.length >= genres_total
        break
      end
    end
    
    # Get Themes
    themes_total = 0
    themes_offset = 0
    @themes_data = Array.new()
    loop do
      response_body = get_giantbomb_api('themes', themes_offset)
      themes_total = response_body['number_of_total_results']
      results = response_body['results']
      themes_offset = themes_offset + results.length
      results.each do |result|
        @themes_data << result
      end
      if @themes_data.length >= themes_total
        break
      end
    end
  end
  
  def search_games
    if params[:query].blank?
      render plain: 'Game not found', status: :not_found
    else
      
    end
  end
  
  private
  def get_game_data (id, get_extra_info) 
    if id
      uri = URI('http://www.gamespot.com/api/games/')
        params = {
          :api_key  => ENV['GAMESPOT_API_KEY'],
          :format   => 'json',
          :filter   => "id:#{id}"
        }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        if response.code == "301"
          response = Net::HTTP.get_response(URI.parse(response.header['location']))
        end
        game_data = JSON.parse(response.body)['results'][0]
        
        if get_extra_info && !game_data.blank?
          # get all resources with api
          game_data['reviews'] = get_gamespot_api('reviews', id)
          game_data['videos'] = get_gamespot_api('videos', id)
          game_data['articles'] = get_gamespot_api('articles', id)
          game_data['releases'] = get_gamespot_api('releases', id)
        end
        
        return game_data
    end
  end
  
  def get_gamespot_api(type, id)
    if id
      uri = URI("http://www.gamespot.com/api/#{type}/")
        params = {
          :api_key  => ENV['GAMESPOT_API_KEY'],
          :format   => 'json',
          :filter   => "association:5000-#{id}",
          :limit    => 5
        }
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
        if response.code == "301"
          response = Net::HTTP.get_response(URI.parse(response.header['location']))
        end
        return JSON.parse(response.body)['results']
    end
  end
  
  def get_giantbomb_api (type, offset)
    uri = URI("https://www.giantbomb.com/api/#{type}/")
    params = {
      :api_key  => ENV['GIANTBOMB_API_KEY'],
      :format   => 'json',
      :sort     => 'name:asc',
      :offset   => offset,
      :limit    => 100
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    if response.code == "301"
      response = Net::HTTP.get_response(URI.parse(response.header['location']))
    end
    
    return JSON.parse(response.body)
  end
end
