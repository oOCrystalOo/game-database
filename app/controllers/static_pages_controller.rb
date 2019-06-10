class StaticPagesController < ApplicationController
  def index
    require 'net/http'
    
    uri = URI('http://www.gamespot.com/api/games/')
    params = { 
      :filter   => 'publisher:nintendo',
      :api_key  => ENV['GAMESPOT_API_KEY'],
      :format   => 'json'
    }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)
    if response.code == "301"
      response = Net::HTTP.get_response(URI.parse(response.header['location']))
    end
    
    render json: JSON.parse(response.body)
  end
end
