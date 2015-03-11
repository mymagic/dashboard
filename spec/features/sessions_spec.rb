require 'rails_helper'

RSpec.describe 'Session', type: :feature, js: false do
  feature "Log in" do
    given(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }

    context 'as administrator' do
      given!(:user) { administrator }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in community, user.email
        expect_to_be_signed_in
      end
    end

    context 'as staff' do
      given!(:user) { staff }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in community, user.email
        expect_to_be_signed_in
      end
    end

    context 'as regular member' do
      given!(:user) { member }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in community, user.email
        expect_to_be_signed_in
      end
    end

    context 'as mentor' do
      given!(:user) { mentor }
      scenario 'logging in' do
        visit root_path
        expect_to_be_signed_out
        log_in community, user.email
        expect_to_be_signed_in
      end
    end
  end
end
