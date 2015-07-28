require 'rails_helper'

RSpec.describe 'Registrations', type: :feature, js: false do
  shared_examples "canceling account" do
    it "cancels the members account" do
      cancel_my_account(community)
      expect(page).
        to have_content('Your account has been successfully cancelled')
    end
  end

  shared_examples "changing first name" do
    background { as_user user }
    it "changes my first name" do
      visit root_path
      within(:css, 'nav.navbar-standard') do
        expect(page).to have_content(user.first_name)
      end
      update_my_account(community: community, first_name: 'NewFirstName')
      within(:css, 'nav.navbar-standard') do
        expect(page).to have_content('NewFirstName')
      end
    end
  end

  shared_examples "changing my notification settings" do
    it 'allows me to disable notifications' do
      expect(user.receive?(:follower_notification)).to be_truthy
      visit root_path
      update_my_account(
        community: community,
        notifications: ['when someone starts following me'])
      expect(user.reload.receive?(:follower_notification)).to be_falsey
    end
  end

  shared_examples "seeing a change password link" do
    it 'displays a link to change my password on MaGIC connect' do
      visit root_path
      within(:css, 'nav.navbar-standard ul.dropdown-menu') do
        expect(page).
          to have_link(
            'Change Password',
            href: 'http://connect.mymagic.my/profile')
      end
    end
  end

  feature "Managing User account" do
    given(:community) { create(:community) }
    given(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }

    context 'as mentor' do
      given(:user) { administrator }
      background { as_user user }
      it_behaves_like 'changing first name'
      it_behaves_like 'canceling account'
      it_behaves_like 'changing my notification settings'
      it_behaves_like 'seeing a change password link'
    end

    context 'as staff' do
      given(:user) { staff }
      background { as_user user }
      it_behaves_like 'changing first name'
      it_behaves_like 'canceling account'
      it_behaves_like 'changing my notification settings'
      it_behaves_like 'seeing a change password link'
    end

    context 'as regular member' do
      given(:user) { member }
      background { as_user user }
      it_behaves_like 'changing first name'
      it_behaves_like 'canceling account'
      it_behaves_like 'changing my notification settings'
      it_behaves_like 'seeing a change password link'
    end

    context 'as mentor' do
      given(:user) { mentor }
      background { as_user user }
      it_behaves_like 'changing first name'
      it_behaves_like 'canceling account'
      it_behaves_like 'changing my notification settings'
      it_behaves_like 'seeing a change password link'
    end
  end
end
