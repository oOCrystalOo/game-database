require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe "static_pages#index" do
    it "should display the page properly" do
      get :index
      expect(response).to have_http_status :success
    end
  end
  
  describe "static_pages#games" do
    it "should display the page properly" do
      get :index
      expect(response).to have_http_status :success
    end
  end
  
  describe "static_pages#game" do
    it "should display the page properly" do
      get :index
      expect(response).to have_http_status :success
    end
  end
end
