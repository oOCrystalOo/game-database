class StaticPagesController < ApplicationController
  def index
    require 'net/http'
    offset = 0
    game_ids = Array.new
    
    # while the number of game ids in the array is less than 10, get more top reviews
    while game_ids.length < 10 do
      uri = URI('http://www.gamespot.com/api/reviews/')
      params = {
        :api_key  => ENV['GAMESPOT_API_KEY'],
        :format   => 'json',
        :sort     => 'score:desc',
        :limit    => 15,
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
      
      # remove duplicates and get first 10
      game_ids = game_ids.uniq[0, 10]
      
      # increase the offset if needed, and run the loop again with the new offset
      if game_ids.length < 10
        offset = offset + 15
      end
    end
    
    # get game data from the 10 ids
    @data = Array.new
    if game_ids.length == 10
      game_ids.each do |id|
        uri = URI('http://www.gamespot.com/api/games/')
        params = {
          :api_key  => ENV['GAMESPOT_API_KEY'],
          :format   => 'json',
          :filter   => id
        }
        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.get_response(uri)
        if response.code == "301"
          response = Net::HTTP.get_response(URI.parse(response.header['location']))
        end
        game_data = JSON.parse(response.body)['results']
        
        @data.push(game_data)
      end
    end
    
    puts @data.inspect
  end
 
end
