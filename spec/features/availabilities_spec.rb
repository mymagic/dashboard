require 'rails_helper'

RSpec.describe 'Availabilities', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let!(:availability) { create(:availability, community: community, member: administrator, slot_duration: 30) }

  before { as_user administrator }

  it 'allow to add new availability' do
    visit community_member_availabilities_path(community, administrator)
    click_on 'New Availability'

    select '15', from: 'availability_start_time_4i'
    select '17', from: 'availability_end_time_4i'
    select '30', from: 'Slot duration'
    select '(GMT+07:00) Bangkok', from: 'Time zone'
    select 'Skype', from: 'Location type'
    fill_in 'Location detail', with: 'MyMaGIC'
    click_on 'Create Availability'

    expect(page).to have_content 'Availability has successfully created.'
  end

  it 'allow to delete an availability' do
    visit community_member_availabilities_path(community, administrator)
    click_on 'Delete'

    expect(page).to have_content 'Availability has successfully deleted.'
    expect(page).to_not have_content availability.date
  end

  it 'generate slots by slot duration' do
    visit community_member_availability_path(community, administrator, availability)

    expect(page).to have_selector 'tbody > tr', count: 4
  end
end
