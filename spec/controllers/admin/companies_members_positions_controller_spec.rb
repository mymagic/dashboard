require 'rails_helper'

RSpec.describe Admin::CompaniesMembersPositionsController, type: :controller do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let(:membership) { create(:companies_members_position, community: community) }

  before { login(administrator) }

  describe "PATCH #approve" do
    it 'set current_member as approver' do
      patch(:approve, id: membership.id, community_id: community)

      expect(membership.reload.approver).to eq(administrator)
      expect(membership.approved).to eq(true)
    end
  end

  describe "DELETE #reject" do
    it 'set current_member as approver' do
      delete(:reject, id: membership.id, community_id: community)
      expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
