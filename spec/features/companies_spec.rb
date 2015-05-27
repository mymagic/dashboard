require 'rails_helper'

RSpec.describe 'Companies', type: :feature, js: false do
  feature "Browsing the companies pages" do
    given!(:community) { create(:community) }
    given!(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given!(:company) { create(:company, community: community) }

    before { as_user administrator }

    scenario 'viewing companies' do
      visit community_companies_path(community)
      expect(page).to have_content(company.name)
    end

    scenario 'viewing the company' do
      visit community_companies_path(community)
      click_on company.name

      expect(page).to have_content(company.name)
      expect(page).to have_content(company.website)
    end
  end

  feature "Manage Company" do
    given!(:community) { create(:community, :with_social_media_services) }
    given!(:position) { create(:position, community: community) }
    given!(:staff) { create(:staff, :confirmed, community: community) }
    given!(:manager) { create(:member, :confirmed, community: community) }
    given!(:company) { create(:company, name: "ACME", community: community) }
    given(:social_media_service) { community.social_media_services.first }
    given(:other_social_media_service) { community.social_media_services.last }
    given!(:social_media_link) do
      create(
        :social_media_link,
        service: social_media_service,
        attachable: company)
    end

    given!(:manager_position) do
      create(
        :companies_members_position,
        :approved,
        :managable,
        position: position,
        member: manager,
        company: company
      )
    end

    def edit_a_company
      visit community_company_path(company.community, company)
      click_link "Edit company info"

      expect(page.find_field('Name').value).to eq 'ACME'

      # General Information
      fill_in 'Name', with: 'New Company Name'
      fill_in 'Description', with: 'This is a company description'
      fill_in 'Website', with: 'http://example.com'
      attach_file(
        'Logo',
        File.join(
          Rails.root, 'spec', 'support', 'companies', 'logos', 'logo.png'))

      # Social Media Links
      # Social Media Links
      fill_in social_media_link.service, with: 'https://facebook.com/handle'
      fill_in other_social_media_service, with: 'Handle'

      click_button 'Save'

      expect(page).to have_content("Company was successfully updated.")

      visit community_company_path(company.community, company)
      expect(page).to have_content("New Company Name")
      expect(page).to have_content("This is a company description")
      expect(page).to have_content("http://example.com")

      expect(page).to have_content(other_social_media_service.camelize)
      expect(page).to have_content('Handle')
      expect(page).to have_link(
        social_media_link.service.camelize, href: 'https://facebook.com/handle')
    end

    context 'as manager' do
      background do
        as_user manager
      end

      scenario 'viewing company page' do
        visit community_company_path(company.community, company)
        expect(page).to have_content("Manage Company")
      end

      scenario 'viewing company edit page' do
        visit community_company_path(company.community, company)
        click_link "Edit company info"
        expect(page).to have_content("Edit Company")
      end

      scenario 'edit a company' do
        edit_a_company
      end
    end

    context 'as staff' do
      background do
        as_user staff
      end

      scenario 'viewing company page' do
        visit community_company_path(company.community, company)
        expect(page).to have_content("Manage Company")
      end

      scenario 'viewing company edit page' do
        visit community_company_path(company.community, company)
        click_link "Edit company info"
        expect(page).to have_content("Edit Company")
      end

      scenario 'edit a company' do
        edit_a_company
      end
    end
  end
end
