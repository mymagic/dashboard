require 'rails_helper'

RSpec.describe Admin::CompaniesMembersPositionsController, type: :controller do
  let(:community) { create(:community) }

  describe "GET #index" do
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe 'assigning companies members positions' do
    let!(:position) { create(:position, community: community) }
    let!(:administrator) { create(:administrator, :confirmed, community: community) }
    let!(:approved_cmp) { create(:companies_members_position, :approved, position: position) }
    let!(:unapproved_cmp) { create(:companies_members_position, position: position) }
    before do
      login(administrator)
      get :index, community_id: community
    end
    it 'assigns the correct approved company member positions' do
      expect(assigns(:approved_companies_members_positions)).to include(approved_cmp)
      expect(assigns(:approved_companies_members_positions)).to_not include(unapproved_cmp)
    end
    it 'assigns the correct unapproved company member positions' do
      expect(assigns(:unapproved_companies_members_positions)).to eq [unapproved_cmp]
    end
  end
end
