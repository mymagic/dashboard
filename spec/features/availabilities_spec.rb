require 'rails_helper'

RSpec.describe 'Availabilities', type: :feature, js: true do
  let(:community) { create(:community) }
  let(:mentor) { create(:administrator, :confirmed, community: community) }
  let(:participant) { create(:staff, :confirmed, community: community) }
  let!(:availability) { create(:availability, community: community, member: mentor, slot_duration: 30) }

  shared_examples_for 'an availability' do
    it 'allow to add new availability' do
      visit community_member_availabilities_path(community, mentor)
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

    it 'generate slots by slot duration' do
      visit community_member_availability_path(community, mentor, availability)

      expect(page).to have_selector 'tbody > tr', count: 4
    end
  end

  context 'as a mentor' do
    it_behaves_like 'an availability'

    before { as_user mentor }

    it 'allow to edit an availability' do
      visit community_member_availabilities_path(community, mentor)

      find('.fc-title').click
      within('.availability-mentor') { click_on 'Edit' }

      expect(page).to have_content 'Edit Availability'

      select '9', from: 'availability_date_3i'
      click_on 'Update Availability'

      expect(page).to have_content 'Availability has successfully updated.'
    end

    it 'allow to destroy an availability' do
      visit community_member_availabilities_path(community, mentor)

      find('.fc-title').click
      within('.availability-mentor') { click_on 'Edit' }

      click_on 'Delete'

      expect(page).to have_content 'Availability has successfully deleted.'
    end

    it 'does not allow to reserve own slots' do
      visit community_member_availabilities_path(community, mentor)

      find('.fc-title').click
      within('.availability-mentor') { click_on 'Edit' }

      expect(page).to_not have_content 'Reserve'
    end
  end

  context 'as a participant' do
    it_behaves_like 'an availability'

    before { as_user participant }

    it 'allow to reserve a slot' do
      visit community_member_availabilities_path(community, mentor)

      find('.fc-title').click
      within('.availability-mentor') { click_on 'Reserve' }
      within('table tbody tr:first-child') { click_on 'Reserve' }

      expect(page).to have_content 'You have successfully reserved the slot.'
    end
  end
end
