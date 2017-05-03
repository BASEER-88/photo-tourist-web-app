require 'rails_helper'

RSpec.describe State, type: :request do

  def json_body
    JSON.parse(response.body)
  end

  describe "API" do
    before(:each) do
      State.delete_all
    end

    it "should be under /api scope" do
      expect(states_path).to eq("/api/states")
    end

    it "GET state" do
        state = State.create(:name=>"state")
        get state_path(state.id)
        expect(response).to have_http_status(:ok)
        expect(json_body["name"]).to eq("state")
    end

    it "returns all required fields" do
      get state_path(State.create(:name=>"state").id)
      expect(json_body).to include('id', 'name', 'created_at', 'updated_at')
    end

    it "should return id in a string form" do
      state_id = State.create(:name=>"state").id
      get state_path(state_id)
      expect(json_body['id']).to eq(state_id.to_s)
    end
  end
end
