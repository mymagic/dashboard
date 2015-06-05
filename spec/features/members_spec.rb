require 'rails_helper'

RSpec.describe 'Members', type: :feature, js: false do
  feature "Company Member Invitation" do
    given(:community) { create(:community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:manager) { create(:member, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given!(:company) { create(:company, name: "ACME", community: community) }
    given!(:position) { create(:position, community: community) }

    shared_examples "following another member" do
      context 'with another member' do
        let!(:other_member) do
          create(:member, :confirmed, community: community)
        end
        scenario 'follow the other member' do
          visit community_member_path(community, other_member)
          click_link 'Follow'
          expect(page).
            to have_content("You are now following #{ other_member.full_name }")
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
            last_name: "Faust",
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
          expect(page).
            to have_content("Your password was set successfully. "\
                            "You are now signed in.")
          visit community_company_path(community, company)
          within ".company__members" do
            expect(page).to have_content("Johann Faust")
          end
        end
      end

    end

    context 'as member' do
      background { as_user member }

      it_behaves_like 'following another member'

      scenario 'viewing company page' do
        visit community_company_path(community, company)
        expect(page).to_not have_content("Manage Company")
      end
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like 'managing the company'
      it_behaves_like 'following another member'
    end

    context 'as manager' do
      background do
        create(
          :companies_members_position,
          :approved,
          :managable,
          position: position,
          member: manager,
          company: company
        )
        as_user manager
      end
      it_behaves_like 'managing the company'
      it_behaves_like 'following another member'
    end
  end
end
