require 'rails_helper'

RSpec.describe Admin::CompaniesMembersPositionsController, type: :controller do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let(:companies_members_position) { create(:companies_members_position, community: community) }

  before { login(administrator) }

  describe "PATCH #approve" do
    it 'set current_member as approver' do
      patch(:approve, id: companies_members_position.id, community_id: community)

      expect(companies_members_position.reload.approver).to eq(administrator)
    end
  end

  describe "DELETE #reject" do
    it 'remove companies_members_position' do
      delete(:reject, id: companies_members_position.id, community_id: community)
      expect { companies_members_position.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
