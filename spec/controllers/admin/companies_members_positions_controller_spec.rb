require 'rails_helper'

RSpec.describe Admin::CompaniesMembersPositionsController, type: :controller do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let(:position) { create(:position, community: community) }
  let!(:pending_cmp) { create(:companies_members_position, position: position) }

  before { login(administrator) }

  describe "PATCH #approve" do
    it 'set current_member as approver' do
      request.env["HTTP_REFERER"] = community_path(community)
      patch(:approve, id: pending_cmp.id, community_id: community)

      expect(pending_cmp.reload.approver).to eq(administrator)
    end
  end

  describe "DELETE #reject" do
    it 'remove companies_members_position' do
      request.env["HTTP_REFERER"] = community_path(community)
      delete(:reject, id: pending_cmp.id, community_id: community)
      expect { pending_cmp.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #index" do
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe 'assigning companies members positions' do
    let!(:approved_cmp) { create(:companies_members_position, :approved, position: position) }

    before do
      login(administrator)
      get :index, community_id: community
    end
    it 'assigns the correct approved company member positions' do
      expect(assigns(:approved_companies_members_positions)).to include(approved_cmp)
      expect(assigns(:approved_companies_members_positions)).to_not include(pending_cmp)
    end
    it 'assigns the correct pending company member positions' do
      expect(assigns(:pending_companies_members_positions)).to eq [pending_cmp]
    end
  end
end