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
end
