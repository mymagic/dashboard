require 'rails_helper'

RSpec.describe 'Members', type: :feature, js: false do
  feature "Company Member Invitation" do
    given!(:staff) { create(:staff, :confirmed) }
    given!(:manager) { create(:member, :confirmed) }
    given!(:member) { create(:member, :confirmed) }
    given!(:company) { create(:company, name: "ACME") }
    given!(:position) { create(:position) }

    context 'as member' do
      background { as_user member }

      scenario 'viewing company page' do
        visit company_path(company)
        expect(page).to_not have_content("Manage Company")
      end
    end

    context 'as staff' do
      background do
        as_user staff
      end

      scenario 'viewing company page' do
        visit company_path(company)
        expect(page).to have_content("Manage Company")
      end

      scenario 'viewing invitation page' do
        visit company_path(company)
        click_link "Invite members to company"
        expect(page).to have_content("Invite New Member to ACME")
        within ".member_companies_positions_company" do
          expect(page).to_not have_content("ACME")
        end

      end

      feature 'inviting a new member to company' do
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
          expect(page).to have_content("Your password was set successfully. You are now signed in.")
          visit company_path(company)
          within ".company-members" do
            expect(page).to have_content("Johann Faust")
          end
        end
      end
    end

    context 'as manager' do
      background do
        CompaniesMembersPosition.create(
          position: position,
          member: manager,
          company: company,
          approved: true,
          can_manage_company: true
        )
        as_user manager
      end

      scenario 'viewing company page' do
        visit company_path(company)
        expect(page).to have_content("Manage Company")
      end

      scenario 'viewing invitation page' do
        visit company_path(company)
        click_link "Invite members to company"
        expect(page).to have_content("Invite New Member to ACME")
        within ".member_companies_positions_company" do
          expect(page).to_not have_content("ACME")
        end

      end

      feature 'inviting a new member to company' do
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
          expect(page).to have_content("Your password was set successfully. You are now signed in.")
          visit company_path(company)
          within ".company-members" do
            expect(page).to have_content("Johann Faust")
          end
        end
      end
    end
  end
end
