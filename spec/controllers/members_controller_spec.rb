require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  describe "GET #index" do
    let(:community) { create(:community) }
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member
  end

  describe "GET #show" do
    let(:community) { create(:community) }
    let(:member) { create(:member, community: community) }
    let(:response) { get(:show, id: member, community_id: community) }
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member
  end
end
