require 'rails_helper'

RSpec.describe State, type: :model do
  describe "MongoDB-backed state" do
    before(:each) do
      State.delete_all
    end

    it "create state with name" do
        state = State.create(:name=>"state")
        expect(State.find(state.id).name).to eq("state")
    end
  end
end
