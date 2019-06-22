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
        puts uri.query.inspect
        response = Net::HTTP.get_response(uri)
        if response.code == "301"
          response = Net::HTTP.get_response(URI.parse(response.header['location']))
        end
        game_data = JSON.parse(response.body)['results'][0]
        
        if get_extra_info
          # get all resources with api
          game_data['reviews'] = get_api('reviews', id)
          game_data['videos'] = get_api('videos', id)
          game_data['articles'] = get_api('articles', id)
          game_data['releases'] = get_api('releases', id)
        end
        
        return game_data
    end
  end
  
  def get_api(type, id)
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
 
end
