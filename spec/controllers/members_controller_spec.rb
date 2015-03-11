require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  describe "GET #index" do
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member do
      let(:response) { get(:index, community_id: current_community.try(:id)) }
    end
  end

  describe "GET #show" do
    let(:member) { create(:member) }
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member do
      let(:response) { get(:show, id: member, community_id: current_community.try(:id)) }
    end
  end
end
