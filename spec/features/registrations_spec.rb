require 'rails_helper'

RSpec.describe 'Registrations', type: :feature, js: false do
  feature "Update User account" do
    given(:administrator) { create(:administrator, :confirmed) }
    given(:staff) { create(:staff, :confirmed) }
    given(:member) { create(:member, :confirmed) }
    given(:mentor) { create(:mentor, :confirmed) }
    context 'as administrator' do
      background { as_user administrator }
      scenario 'changing my first name' do
        visit root_path
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content(administrator.first_name)
        end
        update_my_account(first_name: 'NewFirstName')
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
        update_my_account(first_name: 'NewFirstName')
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content('NewFirstName')
        end
      end
    end

    context 'as regular member' do
      background { as_user member }
      scenario 'changing my first name' do
        visit root_path
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content(member.first_name)
        end
        update_my_account(first_name: 'NewFirstName')
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content('NewFirstName')
        end
      end
    end

    context 'as mentor' do
      background { as_user mentor }
      scenario 'changing my first name' do
        visit root_path
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content(mentor.first_name)
        end
        update_my_account(first_name: 'NewFirstName')
        within(:css, 'nav.navbar-member') do
          expect(page).to have_content('NewFirstName')
        end
      end
    end
  end

  feature "Cancel User account" do
    given(:administrator) { create(:administrator, :confirmed) }
    given(:staff) { create(:staff, :confirmed) }
    given(:member) { create(:member, :confirmed) }
    given(:mentor) { create(:mentor, :confirmed) }

    context 'as administrator' do
      background { as_user administrator }
      scenario 'canceling my account' do
        cancel_my_account
        expect_to_be_signed_out
      end
    end

    context 'as staff' do
      background { as_user staff }
      scenario 'canceling my account' do
        cancel_my_account
        expect_to_be_signed_out
      end
    end

    context 'as regular member' do
      background { as_user member }
      scenario 'canceling my account' do
        cancel_my_account
        expect_to_be_signed_out
      end
    end

    context 'as mentor' do
      background { as_user mentor }
      scenario 'canceling my account' do
        cancel_my_account
        expect_to_be_signed_out
      end
    end
  end
end
