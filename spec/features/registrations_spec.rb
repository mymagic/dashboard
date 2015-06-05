require 'rails_helper'

RSpec.describe 'Registrations', type: :feature, js: false do
  feature "Update User account" do
    given(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }
    context 'as administrator' do
      background { as_user administrator }
      scenario 'changing my first name' do
        visit root_path
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content(administrator.first_name)
        end
        update_my_account(community: community, first_name: 'NewFirstName')
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content('NewFirstName')
        end
      end
    end

    context 'as staff' do
      background { as_user staff }
      scenario 'changing my first name' do
        visit root_path
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content(staff.first_name)
        end
        update_my_account(community: community, first_name: 'NewFirstName')
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content('NewFirstName')
        end
      end
    end

    context 'as regular member' do
      scenario 'changing my first name' do
        as_user member
        visit root_path
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content(member.first_name)
        end
        update_my_account(community: community, first_name: 'NewFirstName')
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content('NewFirstName')
        end
      end
      scenario 'changing my password' do
        as_user member
        visit root_path
        update_my_account(community: community, password: 'newpassword', current_password: 'password0')
        sign_out
        log_in member.community, member.email, 'newpassword'
        expect_to_be_signed_in
      end
    end

    context 'as mentor' do
      background { as_user mentor }
      given(:user) { administrator }
      it_behaves_like 'changing first name'
    end

    context 'as staff' do
      given(:user) { staff }
      it_behaves_like 'changing first name'
    end

    context 'as regular member' do
      given(:user) { member }
      it_behaves_like 'changing first name'
    end

    context 'as mentor' do
      given(:user) { mentor }
      it_behaves_like 'changing first name'
    end
  end

  feature "Cancel User account" do
    given(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "canceling account"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "canceling account"
    end

    context 'as regular member' do
      background { as_user member }
      it_behaves_like "canceling account"
    end

    context 'as mentor' do
      background { as_user mentor }
      it_behaves_like "canceling account"
    end
  end
end
