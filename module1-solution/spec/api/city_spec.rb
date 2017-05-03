require 'rails_helper'

RSpec.describe City, type: :request do

  def json_body
    JSON.parse(response.body)
  end

  describe "API" do
    before(:each) do
      City.delete_all
    end

    it "should be under /api scope" do
      expect(cities_path).to eq("/api/cities")
    end

    it "GET city" do
        city = City.create(:name=>"city")
        get city_path(city.id)
        expect(response).to have_http_status(:ok)
        expect(json_body["name"]).to eq("city")
    end

    it "returns all required fields" do
      get city_path(City.create(:name=>"city").id)
      expect(json_body).to include('id', 'name', 'created_at', 'updated_at')
    end
  end
end
