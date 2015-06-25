require 'rails_helper'

RSpec.describe 'Companies', type: :feature, js: false do
  shared_examples "removing companies" do
    scenario 'destroy a company' do
      visit community_admin_companies_path(community)
      expect(page).to have_content(existing_company.name)
      click_link 'Delete'
      expect(page).to have_content("Company was successfully deleted.")
      expect(page).to_not have_content(existing_company.name)
    end
  end

  shared_examples "administrating companies" do
    scenario 'viewing companies index' do
      visit community_admin_companies_path(community)
      expect(page).to have_content(existing_company.name)
    end

    scenario 'creating a new company' do
      visit community_admin_companies_path(community)
      click_link 'New Company'
      # General Information
      fill_in 'Name', with: 'New Company Name'
      fill_in 'Description', with: 'This is a company description'
      fill_in 'Website', with: 'http://example.com'
      attach_file(
        'company_logo',
        File.join(
          Rails.root, 'spec', 'support', 'companies', 'logos', 'logo.png'))

      # Social Media Links
      fill_in social_media_link.service, with: 'https://facebook.com/handle'
      click_button 'Save'

      expect(page).to have_content("Company was successfully created.")
    end

    scenario 'edit an existing company' do
      visit community_admin_companies_path(community)
      click_link "Edit"

      expect(page.find_field('Name').value).to eq 'ACME'

      # General Information
      fill_in 'Name', with: 'New Company Name'
      fill_in 'Description', with: 'This is a company description'
      fill_in 'Website', with: 'http://example.com'
      attach_file(
        'company_logo',
        File.join(
          Rails.root, 'spec', 'support', 'companies', 'logos', 'logo.png'))

      # Social Media Links
      fill_in social_media_link.service, with: 'https://facebook.com/handle'

      click_button 'Update'

      expect(page).to have_content("Company was successfully updated.")

      visit community_company_path(community, existing_company)
      expect(page).to have_content("New Company Name")
      expect(page).to have_content("This is a company description")
      expect(page).to have_link("example.com", href: 'http://example.com')

      expect(page).to have_link(
        social_media_link.service, href: 'https://facebook.com/handle')
    end
  end

  feature "Managing companies" do
    given!(:community) { create(:community) }
    given!(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given!(:staff) { create(:staff, :confirmed, community: community) }

    given!(:existing_company) do
      create(:company, community: community, name: 'ACME')
    end

    given!(:social_media_service) do
      community.social_media_services << 'other service'
      community.save
      'other service'
    end
    given!(:social_media_link) do
      create(
        :social_media_link,
        service: social_media_service,
        attachable: existing_company)
    end

    context 'as staff member' do
      background do
        as_user staff
      end
      it_behaves_like 'administrating companies'
    end

    context 'as administrator' do
      background do
        as_user administrator
      end
      it_behaves_like 'administrating companies'
      it_behaves_like 'removing companies'
    end
  end
end
