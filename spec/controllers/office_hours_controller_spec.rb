require 'rails_helper'

RSpec.describe OfficeHoursController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #book" do
    it "returns http success" do
      get :book
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #offer" do
    it "returns http success" do
      get :offer
      expect(response).to have_http_status(:success)
    end
  end

end
