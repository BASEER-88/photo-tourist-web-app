require 'rails_helper'

RSpec.describe "Tags", type: :request do
  include_context "db_cleanup_each"
  let(:account) { signup FactoryGirl.attributes_for(:user) }

  context "quick API check" do
    let!(:user) { login account }

    it_should_behave_like "resource index", :tag
    it_should_behave_like "show resource", :tag
    it_should_behave_like "create resource", :tag
    it_should_behave_like "modifiable resource", :tag
  end

  shared_examples "cannot index" do |status=:unauthorized|
    it "index fails with #{status}" do
      jget tags_path
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot show" do |status=:unauthorized|
    it "index fails with #{status}" do
      jget tags_path
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot create" do |status=:unauthorized|
    it "create fails with #{status}" do
      jpost tags_path, tag_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot update" do |status|
    it "update fails with #{status}" do
      jput tag_path(tag_id), FactoryGirl.attributes_for(:tag)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot delete" do |status|
    it "delete fails with #{status}" do
      jdelete tag_path(tag_id), tag_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "can create" do
    it "is created" do
      jpost tags_path, tag_props
      #pp parsed_body
      expect(response).to have_http_status(:created)
      payload=parsed_body
      expect(payload).to include("id")
      expect(payload).to include("name"=>tag_props[:name])
      expect(payload).to include("user_roles")
      expect(payload["user_roles"]).to include(Role::ORGANIZER)
      expect(Role.where(:user_id=>user["id"],:role_name=>Role::ORGANIZER)).to exist
    end
  end
  shared_examples "can update" do
    it "can update" do
      jput tag_path(tag_id), tag_props
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "can delete" do
    it "can delete" do
      jdelete tag_path(tag_id)
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "all fields present" do |user_roles|
    it "list has all fields with user_roles #{user_roles}" do
      jget tags_path
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload.size).to_not eq(0)
      payload.each do |r|
        expect(r).to include("id")
        expect(r).to include("name")
        if user_roles.empty?
          expect(r).to_not include("user_roles")
        else
          expect(r).to include("user_roles")
          expect(r["user_roles"].to_a).to include(*user_roles)
        end
      end
    end
    it "get has all fields with user_roles #{user_roles}" do
      jget tag_path(tag_id)
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id"=>tag.id)
      expect(payload).to include("name"=>tag.name)
      if user_roles.empty?
        expect(payload).to_not include("user_roles")
      else
        expect(payload).to include("user_roles")
        expect(payload["user_roles"].to_a).to include(*user_roles)
      end
    end
  end

  describe "Tag authorization" do
    let(:alt_account) { signup FactoryGirl.attributes_for(:user) }
    let(:admin_account) { apply_admin(signup FactoryGirl.attributes_for(:user)) }
    let(:tag_props) { FactoryGirl.attributes_for(:tag) }
    let(:tag_resources) { 3.times.map { create_resource tags_path, :tag } }
    let(:tag_id)  { tag_resources[0]["id"] }
    let(:tag)     { Tag.find(tag_id) }


    context "caller is unauthenticated" do
      before(:each) { login account; tag_resources; logout }
      it_should_behave_like "cannot index", :forbidden
      it_should_behave_like "cannot show", :forbidden
      it_should_behave_like "cannot create"
      it_should_behave_like "cannot update", :unauthorized
      it_should_behave_like "cannot delete", :unauthorized
      # it_should_behave_like "all fields present", []
    end
    context "caller is authenticated organizer" do
      let!(:user)   { login account }
      before(:each) { tag_resources }
      it_should_behave_like "can create"
      it_should_behave_like "can update"
      it_should_behave_like "can delete"
      it_should_behave_like "all fields present", [Role::ORGANIZER]
    end
    context "caller is authenticated non-organizer" do
      before(:each) { login account; tag_resources; login alt_account }
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "cannot delete", :forbidden
      it_should_behave_like "all fields present", []
    end
    context "caller is admin" do
      before(:each) { login account; tag_resources; login admin_account }
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "can delete"
      it_should_behave_like "all fields present", []
    end

  end

  describe "role merge" do
    it "returns one tag with flattened roles" do
      roles=["foo","bar","baz"]
      originator=FactoryGirl.create(:user)
      tag=FactoryGirl.create(:tag,
                               :creator_id=>originator.id);
      roles.each do |role|
        originator.add_role(role,tag).save
      end
      login originator
      jget tags_path
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      payload=parsed_body
      expect(payload.size).to eq(1)
      expect(payload[0]).to include("user_roles")
      expect(payload[0]["user_roles"]).to include(*roles)
    end
  end
end
