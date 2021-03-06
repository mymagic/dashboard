require 'rails_helper'

RSpec.describe 'Admin/Members', type: :feature, js: false do
  shared_examples "sign up as invited member" do |opts|
    scenario 'open invitiation and sign in' do
      open_email(email)

      expect(current_email).
        to have_content "You have been invited to join #{ community.name }"
      current_email.click_link 'Accept invitation'

      expect(page.find_field('First name').value).to eq 'Johann'
      expect(page.find_field('Last name').value).to eq 'Faust'
      expect(page).to_not have_field('Email')

      click_button 'Join'
      expect(page).
        to have_content(
          "Thank you for updating your profile! You are now signed in.")

      if [:administrator, :staff].include?(opts[:role])
        expect(page).to have_css('nav.navbar-admin')
      else
        expect(page).to_not have_css('nav.navbar-admin')
      end
    end
  end

  feature "Administration" do
    given!(:community) { create(:community) }
    given!(:network) { community.default_network }
    given!(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given!(:staff) { create(:staff, :confirmed, community: community) }
    given!(:member) { create(:member, :confirmed, community: community) }
    given!(:company) { create(:company, community: community) }
    given(:social_media_service) do
      community.social_media_services << 'other service'
      community.save
      'other service'
    end
    given!(:social_media_link) do
      create(
        :social_media_link,
        service: social_media_service,
        attachable: member)
    end

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

        # Position
        select(company.name, from: 'member_positions_attributes_0_company_id')

        # Social Media Links
        fill_in social_media_link.service, with: 'https://facebook.com/handle'

        click_button 'Save'

        expect(page).to have_content("Member was successfully updated.")

        visit community_network_member_path(community, network, member)

        expect(page).to have_content('New First Name')
        expect(page).to have_content('New Last Name')
        expect(page).to have_content(company.name)

        expect(page).
          to have_link(
            social_media_link.service,
            href: 'https://facebook.com/handle')
      end

      scenario 'viewing the user menus' do
        visit community_path(community)
        expect(page).to have_css('nav.navbar-standard')
        expect(page).to have_css('nav.navbar-admin')
        within(:css, 'nav.navbar-admin') do
          expect(page).to have_link('Members')
          expect(page).to have_link('Companies')
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

      scenario 'viewing the user menus' do
        visit root_path
        expect(page).to have_css('nav.navbar-standard')
        expect(page).to have_css('nav.navbar-admin')
        within(:css, 'nav.navbar-admin') do
          expect(page).to have_link('Members')
        end
      end
    end

    context 'as regular member' do
      background { as_user member }

      scenario 'viewing the user menus' do
        visit root_path
        expect(page).to have_css('nav.navbar-standard')
        expect(page).to_not have_css('nav.navbar-admin')
      end

      scenario 'viewing members' do
        visit community_admin_members_path(community)
        expect(page).to have_unauthorized_message
      end
    end
  end

  context 'as an Administrator' do
    let!(:administrator) { create(:administrator, :confirmed) }
    let(:community) { administrator.community }

    let(:other_community) { create(:community) }
    let(:member_of_other_community) do
      create(:member, :confirmed, community: other_community)
    end

    let!(:company) { create(:company, community: community) }

    feature 'inviting a Member who is already member of another community' do
      given(:email) { member_of_other_community.email }
      background do
        allow(MagicConnect).to receive(:user_exists?).and_return(true)
        as_user administrator
        invite_new_member(
          email: email,
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Regular Member',
            company: company.name
          }
        )
        sign_out
      end

      it_behaves_like "sign up as invited member", role: :regular_member
    end

    feature 'inviting a Staff Member' do
      given!(:email) { 'new_member@example.com' }
      background do
        allow(MagicConnect).to receive(:user_exists?).and_return(true)
        as_user administrator
        invite_new_member(
          email: email,
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Staff',
            company: company.name
          }
        )
        sign_out
      end

      it_behaves_like "sign up as invited member", role: :staff
    end

    feature 'inviting a Regular Member' do
      given!(:email) { 'new_member@example.com' }
      background do
        allow(MagicConnect).to receive(:user_exists?).and_return(true)
        as_user administrator
        invite_new_member(
          email: email,
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Regular Member',
            company: company.name
          }
        )
        sign_out
      end

      it_behaves_like "sign up as invited member", role: :regular_member
    end

    feature 'inviting an Administrator' do
      given!(:email) { 'new_member@example.com' }
      background do
        allow(MagicConnect).to receive(:user_exists?).and_return(true)
        as_user administrator
        invite_new_member(
          email: email,
          community: community,
          attributes: {
            first_name: 'Johann',
            last_name: 'Faust',
            role: 'Administrator'
          }
        )
        sign_out
      end

      it_behaves_like "sign up as invited member", role: :administrator
    end
  end
end
