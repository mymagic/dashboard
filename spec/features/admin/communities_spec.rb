require 'rails_helper'

RSpec.describe 'Admin/Communities', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }

    shared_examples "managing community" do
      it "creates a new event" do
        visit community_path(community)
        within '.navbar-admin' do
          click_link "Community"
        end

        # General Information
        fill_in 'Name', with: 'GreatCommunity'
        fill_in 'Social media services', with: 'Hogwards, MIT'

        click_button 'Update Community'

        expect(page).to have_content('Community was successfully updated.')

        within '.navbar-member .navbar-brand' do
          expect(page).to have_content 'GreatCommunity'
        end
      end
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "managing community"
    end
  end
end
