require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe "static_pages#index" do
    it "should display the landing page properly" do
      get :index
      expect(response).to have_http_status :success
    end
  end
  
  describe "static_pages#games action" do
    it "should display the games list properly" do
      get :games
      expect(response).to have_http_status :success
    end
  end
  
  describe "static_pages#game action" do
    it "should not display the individual game page if the ID is incorrect" do
      get :game, params: { use_route: 'game/', id: "blah"}
      expect(response).to have_http_status :not_found
    end
    
    it "should display the individual game page" do
      #game id 1272 is LoZ OoT
      get :game, params: { use_route: 'game/', id: '1272' }
      expect(response).to have_http_status :success
    end
  end
  
  describe "static_pages#search action" do
    it "should display the search page properly" do
      get :search
      expect(response).to have_http_status :success
    end
  end
  
  describe "static_pages#search_games action" do
    it "should throw an error when no query is entered" do
      get :search_games
      expect(response).to have_http_status :not_found
    end
    
    it "should return the search results successfully with one filter" do
      # Platforms ID 3 is Gameboy, Genre ID 1 is Action
      get :search_games, params: { use_route: 'search_games/', data: { platforms: 90 } }
      expect(response).to have_http_status :success
      response_value = ActiveSupport::JSON.decode(@response.body)
      expect(response_value).not_to be_empty
    end
    
    it "should return the search results successfully with multiple filters" do
      # Platforms ID 3 is Gameboy, Genre ID 1 is Action
      get :search_games, params: { use_route: 'search_games/', data: { platforms: 3, original_release_date: '|1980-12-31' } }
      expect(response).to have_http_status :success
      response_value = ActiveSupport::JSON.decode(@response.body)
      expect(response_value).not_to be_empty
    end
  end
  
  describe "static_pages#get_game_by_name action" do
    it "should return page not found if no name is given" do
      get :get_game_by_name
      expect(response).to have_http_status :not_found
    end
    
    it "should successfully get the game by name, and then redirect to the game page with id" do
      get :get_game_by_name, params: { use_route: 'get_game_by_name/', data: { name: 'Dr. Mario' } }
      #expect(response).to redirect_to game_path
    end
  end
end
