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
    # Get Platforms
    @platforms_data = get_select_options('platforms')
  end
  
  def search_games
    params = request.query_parameters
    puts params.inspect
    if params.blank?
      render plain: 'Game not found', status: :not_found
    else
      if params["data"]
        params = params["data"]
      end
      
      filter = '';
      offset = 0
      params.each do |param_name, value| 
        if param_name == 'offset'
          offset = value
        else
          if filter.length > 0
            filter = filter + ','
          end
          filter = filter + "#{param_name}:#{value}"
        end
      end
      
      @data = get_giantbomb_api('games', offset, filter)
      
      render json: @data
    end
  end
  
  def get_game_by_name
    params = request.query_parameters
    puts params.inspect
    if params.blank?
      render plain: 'Game not found', status: :not_found
    else
      require 'net/http'
      
      
    end
  end
  
  private
  def get_game_data (id, get_extra_info) 
    require 'net/http'
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
    require 'net/http'
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
  
  def get_giantbomb_api (type, offset, filter)
    require 'net/http'
    uri = URI("https://www.giantbomb.com/api/#{type}/")
    params = {
      :api_key  => ENV['GIANTBOMB_API_KEY'],
      :format   => 'json',
      :sort     => 'name:asc',
      :offset   => offset,
      :limit    => 100
    }
    if filter.length > 0
      params[:filter] = filter
    end
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    if response.code == "301"
      response = Net::HTTP.get_response(URI.parse(response.header['location']))
    end
    
    return JSON.parse(response.body)
  end
  
  def get_select_options (type)
    require 'net/http'
    total = 0
    offset = 0
    data = Array.new()
    loop do
      response_body = get_giantbomb_api(type, offset, '')
      total = response_body['number_of_total_results']
      results = response_body['results']
      offset = offset + results.length
      results.each do |result|
        data << result
      end
      if data.length >= total
        break
      end
    end
    
    return data
  end
end
