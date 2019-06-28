class ApplicationController < ActionController::Base
  def call_api(endpoint, body)
    require 'net/https'
    http = Net::HTTP.new('api-v3.igdb.com', 80)
    request = Net::HTTP::Get.new(URI("https://api-v3.igdb.com/#{endpoint}"), {'user-key' => ENV['IGDB_API_KEY']})
    request.body = body
    return http.request(request).body
  end
  
  def get_platforms ()
    @platforms = call_api('platforms', "fields *;")
  end
end
