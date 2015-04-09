require 'rails_helper'

RSpec.describe 'Admin/Members', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community, :with_social_media_services) }
    given!(:administrator) { create(:administrator, :confirmed, community: community) }
    given!(:staff) { create(:staff, :confirmed, community: community) }
    given!(:member) { create(:member, :confirmed, community: community) }
    given!(:company) { create(:company, community: community) }
    given!(:social_media_link) { create(:social_media_link, attachable: member) }
    given(:social_media_service) { community.social_media_services.sample }

    context 'as administrator' do
      background { as_user administrator }

      scenario 'viewing members' do
        visit community_admin_members_path(community)
        expect(page).to have_content(administrator.first_name)
        expect(page).to have_content(staff.first_name)
        expect(page).to have_content(member.first_name)
      end

      scenario 'editing member' do
        visit edit_community_admin_member_path(community, member)

        # General Information
        fill_in 'First name', with: 'New First Name'
        fill_in 'Last name', with: 'New Last Name'

        within '.member_companies_positions_company:first-child' do
          select company.name, from: 'Company'
        end

        # Social Media Links
        within '.social_media_link:first-child' do
          select social_media_link.service.camelize, from: 'Service'
          fill_in 'Handle', with: 'https://facebook.com/handle'
        end

        within '.social_media_link:last-child' do
          select social_media_service.camelize, from: 'Service'
          fill_in 'Handle', with: 'Handle'
        end

        click_button 'Save'

        expect(page).to have_content("Member was successfully updated.")

        visit community_member_path(community, member)

        expect(page).to have_content('New First Name')
        expect(page).to have_content('New Last Name')

        expect(page).to have_content(social_media_service.camelize)
        expect(page).to have_content('Handle')
        expect(page).to have_link(social_media_link.service.camelize, href: 'https://facebook.com/handle')
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
          expect(page).to have_content('Companies')
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

        expect(current_email).to have_content "You have been invited to join #{ community.name }"
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

        expect(current_email).to have_content "You have been invited to join #{ community.name }"
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

        expect(current_email).to have_content "You have been invited to join #{ community.name }"
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

        expect(current_email).to have_content "You have been invited to join #{ community.name }"
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
