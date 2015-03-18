require 'rails_helper'

RSpec.describe 'Session', type: :feature, js: false do
  feature "Log in" do
    given(:administrator) { create(:administrator, :confirmed) }
    given(:staff) { create(:staff, :confirmed) }
    given(:member) { create(:member, :confirmed) }
    given(:mentor) { create(:mentor, :confirmed) }

    context 'as administrator' do
      given!(:user) { administrator }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in user.email
        expect_to_be_signed_in
      end
    end

    context 'as staff' do
      given!(:user) { staff }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in user.email
        expect_to_be_signed_in
      end
    end

    context 'as regular member' do
      given!(:user) { member }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in user.email
        expect_to_be_signed_in
      end
    end

    context 'as mentor' do
      given!(:user) { mentor }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in user.email
        expect_to_be_signed_in
      end
    end
  end
end
