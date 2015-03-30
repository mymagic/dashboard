require 'rails_helper'

RSpec.describe 'Passwords', type: :feature, js: false do
  feature "Password" do
    given!(:administrator) { create(:administrator, :confirmed) }
    given!(:staff) { create(:staff, :confirmed) }
    given!(:member) { create(:member, :confirmed) }
    given!(:mentor) { create(:mentor, :confirmed) }

    context 'as administrator' do
      scenario 'reset' do
        expect_successful_password_reset(administrator)
      end
    end

    context 'as staff' do
      scenario 'reset' do
        expect_successful_password_reset(staff)
      end
    end

    context 'as regular member' do
      scenario 'reset' do
        expect_successful_password_reset(member)
      end
    end

    context 'as mentor' do
      scenario 'reset' do
        expect_successful_password_reset(mentor)
      end
    end
  end
end
