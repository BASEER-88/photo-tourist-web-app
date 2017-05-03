require 'rails_helper'

RSpec.describe City, type: :model do
  describe "RDBMS-backed city" do
    it "create city with name" do
        city = City.create(:name=>"city")
        expect(City.find(city.id).name).to eq("city")
    end
  end
end
