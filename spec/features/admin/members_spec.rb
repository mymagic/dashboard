require 'rails_helper'

RSpec.describe 'Admin/Members', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community) }
    given!(:administrator) { create(:administrator, :confirmed, community: community) }
    given!(:staff) { create(:staff, :confirmed, community: community) }
    given!(:member) { create(:member, :confirmed, community: community) }

    context 'as administrator' do
      background { as_user administrator }

      scenario 'viewing members' do
        visit community_admin_members_path(community)
        expect(page).to have_content(administrator.first_name)
        expect(page).to have_content(staff.first_name)
        expect(page).to have_content(member.first_name)
      end

      scenario 'viewing dashboard' do
        visit community_admin_dashboard_path(community)
        expect(page).to have_css('nav.navbar-admin')
      end

      scenario 'viewing the user menus' do
        visit community_path(community)
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
        visit community_admin_members_path(community)
        expect(page).to have_content(administrator.first_name)
        expect(page).to have_content(staff.first_name)
        expect(page).to have_content(member.first_name)
      end

      scenario 'viewing dashboard' do
        visit community_admin_dashboard_path(community)
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
        visit community_admin_members_path(community)
        expect(page).to have_unauthorized_message
      end

      scenario 'viewing dashboard' do
        visit community_admin_dashboard_path(community)
        expect(page).to have_unauthorized_message
      end
    end
  end

  context 'as a Administrator' do
    let!(:administrator) { create(:administrator, :confirmed) }
    let!(:community) { administrator.community }

    let!(:other_community) { create(:community) }
    let!(:member_of_other_community) do
      create(:member, :confirmed, community: other_community)
    end

    let!(:company) { create(:company, community: community) }
    let!(:position) { create(:position, community: community) }

    feature 'inviting a Member who is already member of another community' do
      background do
        skip "Enable me as soon as working on it"
        as_user administrator
        invite_new_member(
          email: member_of_other_community.email,
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Regular Member',
            company: company.name,
            position: position.name
          }
        )
        sign_out
      end

      scenario 'Sign up as invited member' do
        open_email(member_of_other_community.email)
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

    feature 'inviting a Regular Member' do
      background do
        as_user administrator
        invite_new_member(
          email: 'new_member@example.com',
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Regular Member',
            company: company.name,
            position: position.name
          }
        )
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

    feature 'inviting a Regular Member' do
      background do
        as_user administrator
        invite_new_member(
          email: 'new_member@example.com',
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Regular Member',
            company: company.name,
            position: position.name
          }
        )
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
          email: 'new_member@example.com',
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Administrator'
          }
        )
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
