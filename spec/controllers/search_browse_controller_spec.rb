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
end
