require 'rails_helper'

RSpec.describe 'Network', type: :feature, js: false do
  shared_examples "administrating networks" do
    scenario 'viewing networks index' do
      visit community_admin_networks_path(community)
      expect(page).to have_content(existing_network.name)
    end

    scenario 'creating a new network' do
      visit community_admin_networks_path(community)
      click_link 'New Network'

      fill_in 'Name', with: 'New Network Name'
      click_button 'Save'

      expect(page).to have_content("Network was successfully created.")
    end

    scenario 'edit an existing network' do
      visit community_admin_networks_path(community)
      click_link "Edit"

      expect(page.find_field('Name').value).to eq 'Existing Network'

      fill_in 'Name', with: 'New Network Name'
      click_button 'Update'

      expect(page).to have_content("Network was successfully updated.")

      expect(page).to have_content("New Network Name")
    end
  end

  feature "Managing networks" do
    given!(:community) { create(:community) }
    given!(:existing_network) do
      network = community.networks.first
      network.name = 'Existing Network'
      network.save
      network
    end
    given!(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given!(:staff) { create(:staff, :confirmed, community: community) }

    context 'as staff member' do
      background do
        as_user staff
      end
      it_behaves_like 'administrating networks'
    end

    context 'as administrator' do
      background do
        as_user administrator
      end
      it_behaves_like 'administrating networks'
    end
  end
end
