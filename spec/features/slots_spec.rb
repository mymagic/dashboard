require 'rails_helper'

RSpec.describe 'Slots', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let!(:availability) { create(:availability, community: community, member: administrator, slot_duration: 30) }

  before { as_user administrator }

  it 'allow to reserve a slot' do
    visit community_member_availability_path(community, administrator, availability)

    within 'tbody > tr:first' do
      click_on 'Reserve'
    end

    expect(page).to have_content 'You have successfully reserved the slot.'
    expect(page).to have_content administrator.full_name
  end
end
