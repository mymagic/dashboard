require 'rails_helper'

RSpec.describe 'Admin/CompaniesMembersPositions', type: :feature, js: false do
  feature "Administration" do
    given(:community) { create(:community) }
    given(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given(:staff) { create(:staff, :confirmed, community: community) }

    given!(:approved_position) do
      create(
        :companies_members_position,
        :approved,
        position: create(:position, community: community)
      )
    end
    given!(:pending_position) do
      create(
        :companies_members_position,
        position: create(:position, community: community)
      )
    end
    given!(:reject_position) do
      create(
        :companies_members_position,
        position: create(:position, community: community)
      )
    end

    shared_examples "manage companies members position" do
      it do
        visit community_admin_companies_members_positions_path(community)
        manage_company_members_positions(
          approved: [approved_position],
          approve:  [pending_position],
          reject:   [reject_position]
        )
      end
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "manage companies members position"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "manage companies members position"
    end
  end
end
