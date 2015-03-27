require 'rails_helper'

RSpec.describe 'Registrations', type: :feature, js: false do
  feature "Update User account" do
    given(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }
    context 'as administrator' do
      given(:user) { administrator }
      it_behaves_like 'changing first name'
    end

    context 'as staff' do
      given(:user) { staff }
      it_behaves_like 'changing first name'
    end

    context 'as regular member' do
      given(:user) { member }
      it_behaves_like 'changing first name'
    end

    context 'as mentor' do
      given(:user) { mentor }
      it_behaves_like 'changing first name'
    end
  end

  feature "Cancel User account" do
    given(:community) { create(:community) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:member) { create(:member, :confirmed, community: community) }
    given(:mentor) { create(:mentor, :confirmed, community: community) }

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "canceling account"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "canceling account"
    end

    context 'as regular member' do
      background { as_user member }
      it_behaves_like "canceling account"
    end

    context 'as mentor' do
      background { as_user mentor }
      it_behaves_like "canceling account"
    end
  end
end
