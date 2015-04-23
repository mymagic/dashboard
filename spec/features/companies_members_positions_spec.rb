require 'rails_helper'

RSpec.describe 'CompaniesMembersPositions', type: :feature, js: false do
  feature "Manage a Company's Members Positions" do
    given(:community) { create(:community, :with_social_media_services) }
    given(:position) { create(:position, community: community) }
    given(:administrator) { create(:staff, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:manager) { create(:member, :confirmed, community: community) }
    given(:company) { create(:company, name: "ACME", community: community) }

    given!(:approved_position) do
      create(
        :companies_members_position,
        :approved,
        :managable,
        position: position,
        member: manager,
        company: company
      )
    end

    given!(:remove_position) do
      create(
        :companies_members_position,
        :approved,
        position: create(:position, community: community),
        company: company
      )
    end

    given!(:pending_position) do
      create(
        :companies_members_position,
        position: create(:position, community: community),
        company: company
      )
    end
    given!(:reject_position) do
      create(
        :companies_members_position,
        position: create(:position, community: community),
        company: company
      )
    end
    given!(:update_position) do
      create(
        :companies_members_position,
        :approved,
        position: create(:position, community: community),
        company: company
      )
    end

    shared_examples "manage company's members position" do
      it do
        visit community_company_path(company.community, company)
        click_link "Manage members positions"

        within '.page-header' do
          expect(page).to have_content("#{ company.name } Members Positions")
        end
        manage_company_members_positions(
          approved: manager.companies_positions.where(company: company),
          approve: [pending_position],
          reject: [reject_position],
          remove: [remove_position],
          update: [update_position]
        )
      end
    end

    context 'as manager' do
      background { as_user manager }
      it_behaves_like "manage company's members position"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "manage company's members position"
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "manage company's members position"
    end
  end
end
