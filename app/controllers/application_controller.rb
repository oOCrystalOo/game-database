class ApplicationController < ActionController::Base
  before_action :get_all_platforms
  
  def call_api(endpoint, body)
    require 'net/https'
    http = Net::HTTP.new('api-v3.igdb.com', 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new(URI("https://api-v3.igdb.com/#{endpoint}"), {'user-key' => ENV['IGDB_API_KEY']})
    request.body = body
    response = http.request(request)
    if response.code == "301"
      response = Net::HTTP.get_response(URI.parse(response.header['location']))
    end
    return response.body
  end
  
  def get_all_platforms
    @platforms = JSON.parse(call_api('platforms', "fields *;"))
  end
  
  def not_found
    render plain: 'Game not found', status: :not_found
  end
  
  def get_images_by_id(array, endpoint)
    if !array.kind_of?(Array)
      array = [ array ]
    end
    
    # Limit is 10 per call for free tier
    if array.length > 10
      response = Array.new()
      smaller_arrays = array.each_slice(10).to_a
      smaller_arrays.each do |array|
        res = _get_images(array, endpoint)
        res.each do |r|
          response << r
        end
      end
    else
      response = _get_images(array, endpoint)
    end
    return response
  end
  
  def _get_images(array, endpoint)
    ids = array.join(',')
    request = "fields url; where id = (#{ids});"
    response = JSON.parse(call_api(endpoint, request))
    response.each do |image_hash|
      # Replace t_thumb with t_1080p for high quality image
      if !image_hash['url'].nil?
        image_hash['url'].sub! 't_thumb', 't_1080p'
      else
        puts image_hash.inspect
      end
    end
    return response
  end
end
