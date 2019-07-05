class ApplicationController < ActionController::Base
  # before_action :get_all_platforms
  
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
    @platforms = call_api('platforms', "fields *;")
  end
end
