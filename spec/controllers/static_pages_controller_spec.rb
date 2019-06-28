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
    it "should display a status not found if no game id is passed" do
      get :game
      expect(response).to have_http_status :not_found
    end
    
    it "should display a status not found if game id is passed but not correct" do
      get :game, params: { id: "SOME_GAME" }
      expect(response).to have_http_status :not_found
    end
    
    it "should display the game data correctly" do
      # ID 115276 is Super Mario Maker 2
      get :game, params: { id: 115276 }
      expect(response).to have_http_status :success
    end
  end
end
