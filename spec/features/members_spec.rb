require 'rails_helper'

RSpec.describe 'Members', type: :feature, js: false do
  feature 'Community Members' do
    given!(:community) { create(:community) }
    given!(:staff) { create(:staff, :confirmed, community: community) }
    given!(:regular_member) do
      create(:member, :confirmed, community: community)
    end
    given!(:mentor) { create(:mentor, :confirmed, community: community) }
    given!(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given(:company) { create(:company, name: "ACME", community: community) }
    given(:founder) { create(:member, :confirmed, community: community) }
    before do
      create(:position, founder: true, member: founder, company: company)
    end

    shared_examples "filtering the directory" do
      context 'on the community directory' do
        background { visit community_members_path(community) }
        scenario 'showing all members' do
          within '.member-group' do
            [administrator, staff, regular_member, mentor, founder].each do |m|
              expect(page).to have_content m.send(:full_name)
            end
          end
        end
        scenario 'showing all mentors' do
          within '.filter-navigation' do
            click_link 'Mentors'
          end
          within '.member-group' do
            expect(page).to have_content mentor.full_name
            [administrator, staff, regular_member, founder].each do |m|
              expect(page).to_not have_content m.send(:full_name)
            end
          end
        end
        scenario 'showing all staff and administrators' do
          within '.filter-navigation' do
            click_link 'Staff'
          end
          within '.member-group' do
            expect(page).to have_content administrator.full_name
            expect(page).to have_content staff.full_name
            [regular_member, mentor, founder].each do |m|
              expect(page).to_not have_content m.send(:full_name)
            end
          end
        end
        scenario 'showing all regular members' do
          within '.filter-navigation' do
            click_link 'Members'
          end
          within '.member-group' do
            expect(page).to have_content regular_member.full_name
            expect(page).to have_content founder.full_name
            [administrator, staff, mentor].each do |m|
              expect(page).to_not have_content m.send(:full_name)
            end
          end
        end
        scenario 'showing all founders' do
          within '.filter-navigation' do
            click_link 'Founders'
          end
          within '.member-group' do
            expect(page).to have_content founder.full_name
            [administrator, staff, mentor, regular_member].each do |m|
              expect(page).to_not have_content m.send(:full_name)
            end
          end
        end
      end
    end

    shared_examples "browsing a member page" do
      context 'with another member' do
        let!(:other_member) do
          create(
            :member,
            :confirmed,
            community: community,
            description: 'A happy member of this community.')
        end
        before { create(:position, member: other_member, company: company) }

        scenario 'see member info' do
          visit community_member_path(community, other_member)
          within '.member__details' do
            expect(page).to have_content('A happy member of this community.')
            expect(page).to have_content(company.name)
          end
        end
        scenario 'follow the other member' do
          visit community_member_path(community, other_member)
          click_link 'Follow'
          expect(page).
            to have_content("You are now following #{ other_member.full_name }")

          open_email(other_member.email)
          expect(current_email.subject).
            to eq "#{ member.full_name } has started following you"
        end
      end
    end

    shared_examples "managing the company" do
      scenario "view the manage company menu" do
        visit community_company_path(community, company)
        expect(page).to have_content("Manage Company")
      end

      scenario 'visiting the invitiation page' do
        visit community_company_path(community, company)
        click_link "Invite members to company"
        expect(page).to have_content("Invite New Member to ACME")
      end

      context 'with an invited member' do
        background do
          invite_new_company_member(
            company,
            'new_member@example.com',
            first_name: "Johann",
            last_name: "Faust")
          sign_out
        end

        scenario 'Sign up as invited member' do
          open_email('new_member@example.com')
          current_email.click_link 'Accept invitation'

          expect(page.find_field('First name').value).to eq 'Johann'
          expect(page.find_field('Last name').value).to eq 'Faust'
          expect(page).to_not have_field('Email')

          click_button 'Join'
          expect(page).
            to have_content("Thank you for updating your profile! "\
                            "You are now signed in.")
          visit community_company_path(community, company)
          within ".company__members" do
            expect(page).to have_content("Johann Faust")
          end
        end
      end
    end

    context 'as member' do
      given(:member) { regular_member }
      background { as_user member }
      it_behaves_like 'browsing a member page'
      it_behaves_like 'filtering the directory'

      scenario 'viewing company page' do
        visit community_company_path(community, company)
        expect(page).to_not have_content("Manage Company")
      end
    end

    context 'as staff' do
      given(:member) { staff }
      background { as_user member }
      it_behaves_like 'browsing a member page'
      it_behaves_like 'managing the company'
      it_behaves_like 'filtering the directory'
    end

    context 'as founder' do
      given(:member) { founder }
      background { as_user member }
      it_behaves_like 'browsing a member page'
      it_behaves_like 'managing the company'
      it_behaves_like 'filtering the directory'
    end
  end
end
