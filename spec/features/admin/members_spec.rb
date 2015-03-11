require 'rails_helper'

RSpec.describe 'Admin/Members', type: :feature, js: false do
  feature "Administration" do
    given!(:administrator) { create(:administrator, :confirmed) }
    given!(:staff) { create(:staff, :confirmed) }
    given!(:member) { create(:member, :confirmed) }

    context 'as administrator' do
      background { as_user administrator }

      scenario 'viewing members' do
        visit community_admin_members_path(@current_community)
        expect(page).to have_content(administrator.first_name)
        expect(page).to have_content(staff.first_name)
        expect(page).to have_content(member.first_name)
      end

      scenario 'viewing dashboard' do
        visit admin_dashboard_path
        expect(page).to have_css('nav.navbar-admin')
      end

      scenario 'viewing the user menus' do
        visit root_path
        expect(page).to have_css('nav.navbar-member')
        expect(page).to have_css('nav.navbar-admin')
        within(:css, 'nav.navbar-admin') do
          expect(page).to have_content('Members')
          expect(page).to have_content('Companies')
          expect(page).to have_content('Positions')
          expect(page).to have_content('Office Hours')
        end
      end
    end

    context 'as staff' do
      background { as_user staff }

      scenario 'viewing members' do
        visit community_admin_members_path(@current_community)
        expect(page).to have_content(administrator.first_name)
        expect(page).to have_content(staff.first_name)
        expect(page).to have_content(member.first_name)
      end

      scenario 'viewing dashboard' do
        visit admin_dashboard_path
        expect(page).to have_css('nav.navbar-admin')
      end

      scenario 'viewing the user menus' do
        visit root_path
        expect(page).to have_css('nav.navbar-member')
        expect(page).to have_css('nav.navbar-admin')
        within(:css, 'nav.navbar-admin') do
          expect(page).to have_content('Members')
          expect(page).to_not have_content('Companies')
          expect(page).to_not have_content('Positions')
          expect(page).to_not have_content('Office Hours')
        end
      end
    end

    context 'as regular member' do
      background { as_user member }

      scenario 'viewing the user menus' do
        visit root_path
        expect(page).to have_css('nav.navbar-member')
        expect(page).to_not have_css('nav.navbar-admin')
      end

      scenario 'viewing members' do
        visit community_admin_members_path(@current_community)
        expect(page).to have_unauthorized_message
      end

      scenario 'viewing dashboard' do
        visit admin_dashboard_path
        expect(page).to have_unauthorized_message
      end
    end
  end

  context 'as a Administrator' do
    let!(:administrator) { create(:administrator, :confirmed) }
    let!(:company) { create(:company) }
    let!(:position) { create(:position) }
    feature 'inviting a Regular Member' do
      background do
        as_user administrator
        invite_new_member(
          'new_member@example.com',
          first_name: 'Johann',
          last_name: 'Faust',
          role: 'Regular Member',
          company: company.name,
          position: position.name)
        sign_out
      end

      scenario 'Sign up as invited member' do
        open_email('new_member@example.com')
        current_email.click_link 'Accept invitation'

        expect(page.find_field('First name').value).to eq 'Johann'
        expect(page.find_field('Last name').value).to eq 'Faust'
        expect(page).to_not have_field('Email')

        fill_in 'member[password]', with: 'password0'
        fill_in 'member[password_confirmation]', with: 'password0'
        click_button 'Set my password'
        expect(page).to have_content("Your password was set successfully. You are now signed in.")
        expect(page).to_not have_css('nav.navbar-admin')
      end
    end

    feature 'inviting an Administrator' do
      background do
        as_user administrator
        invite_new_member(
          'new_member@example.com',
          first_name: 'Johann',
          last_name: 'Faust',
          role: 'Administrator')
        sign_out
      end

      scenario 'Sign up as invited member' do
        open_email('new_member@example.com')
        current_email.click_link 'Accept invitation'

        expect(page.find_field('First name').value).to eq 'Johann'
        expect(page.find_field('Last name').value).to eq 'Faust'
        expect(page).to_not have_field('Email')

        fill_in 'member[password]', with: 'password0'
        fill_in 'member[password_confirmation]', with: 'password0'
        click_button 'Set my password'
        expect(page).to have_content("Your password was set successfully. You are now signed in.")
        expect(page).to have_css('nav.navbar-admin')
      end
    end
  end
end
