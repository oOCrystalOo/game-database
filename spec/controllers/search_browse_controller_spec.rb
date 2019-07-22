require 'rails_helper'

RSpec.describe SearchBrowseController, type: :controller do
  describe "search_browse#search action" do
    it "should return game not found if search input is empty" do
      get :search
      expect(response).to have_http_status :not_found
    end
    
    it "should display the results if term is entered" do
      get :search, params: { search: "mario" }
      expect(response).to have_http_status :success
    end
  end
  
  describe "search_browse#browse action" do
    it "should get all platforms, genres, and themes successfully" do
      get :browse
      expect(response).to have_http_status :success
    end
  end
  
  describe "search_browse#browse_games action" do
    it "should return game not found if no params are set" do
      get :browse_games
      expect(response).to have_http_status :not_found
    end
    it "should search and retrieve games with the selected qualities" do
      get :browse_games, params: { platform: 130 }
      expect(response).to have_http_status :success
    end
  end
end
