require 'rails_helper'

RSpec.describe 'Admin/Communities', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }

    shared_examples "managing community" do
      it "creates a new event" do
        visit community_path(community)
        within '.navbar-admin' do
          click_link "Settings"
        end

        # General Information
        fill_in 'Name', with: 'GreatCommunity'
        fill_in 'Social media services', with: 'Hogwards, MIT'

        fill_in 'Email', with: 'email@greatcommunity.local'

        click_button 'Update Settings'

        expect(page).to have_content('Settings were successfully updated.')

      end
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "managing community"
    end
  end
end
