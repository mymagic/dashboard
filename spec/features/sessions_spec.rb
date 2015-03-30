require 'rails_helper'

RSpec.describe 'Session', type: :feature, js: false do
  feature "Log in and Log out" do
    given(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }

    context 'as administrator' do
      given!(:user) { administrator }
      it_behaves_like "logging in"
      it_behaves_like "logging out"
    end

    context 'as staff' do
      given!(:user) { staff }
      it_behaves_like "logging in"
      it_behaves_like "logging out"
    end

    context 'as regular member' do
      given!(:user) { member }
      it_behaves_like "logging in"
      it_behaves_like "logging out"
    end

    context 'as mentor' do
      given!(:user) { mentor }
      it_behaves_like "logging in"
      it_behaves_like "logging out"
    end
  end
end
