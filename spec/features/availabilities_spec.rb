require 'rails_helper'

RSpec.describe 'Availabilities', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:network) { community.networks.first }
  let(:mentor) { create(:member, :confirmed, community: community) }
  let(:participant) { create(:member, :confirmed, community: community) }
  let!(:availability) do
    create(:availability,
           network: network,
           member: mentor,
           slot_duration: 30)
  end

  shared_examples_for 'creating an availability' do
    let(:next_year) { 1.year.from_now.year }
    it 'creates a availability' do
      visit community_path(community)

      within '.navbar-standard' do
        click_on 'Setup Office Hours'
      end

      select next_year, from: 'availability_date_1i'
      select 'January', from: 'availability_date_2i'
      select '1', from: 'availability_date_3i'
      select '15', from: 'availability_start_time_4i'
      select '17', from: 'availability_end_time_4i'
      select '30', from: 'Slot duration'
      select '(GMT+07:00) Bangkok', from: 'Time zone'
      select 'Skype', from: 'Location type'
      fill_in 'Location detail', with: 'MyMaGIC'
      click_on 'Create Availability'

      expect(page).to have_content 'Availability was successfully created.'

      visit community_path(community)
      within '.activity-group' do
        expect(page).
          to have_content("#{ member.full_name } setup office hours on "\
                          "January 01, #{ next_year }")
      end
    end
  end

  context 'as a mentor' do
    let(:member) { mentor }
    before { as_user member }

    it_behaves_like 'creating an availability'

    it 'allow to edit an availability' do
      visit(
        community_network_member_availability_slots_path(
          community,
          network,
          member,
          year: availability.date.year,
          month: availability.date.month,
          day: availability.date.day))

      click_link 'Edit'

      expect(page).to have_content 'Edit Office Hour'

      select '9', from: 'availability_date_3i'
      click_on 'Update Availability'

      expect(page).to have_content 'Availability was successfully updated.'
    end

    it 'allows me to destroy my availability' do
      visit(
        edit_community_network_member_availability_path(community, network, member, availability)
      )

      click_on 'Delete'

      expect(page).to have_content 'Availability was successfully deleted.'
    end

    it 'generated slots by slot duration' do
      visit(
        community_network_member_availability_slots_path(
          community,
          network,
          availability.member,
          year: availability.date.year,
          month: availability.date.month,
          day: availability.date.day))

      expect(page).to have_selector 'tbody > tr', count: 4
    end

    it 'does not allow to reserve own slots' do
      visit(
        community_network_member_availability_slots_path(
          community,
          network,
          availability.member,
          year: availability.date.year,
          month: availability.date.month,
          day: availability.date.day))

      expect(page).to_not have_content 'Reserve'
    end
  end

  context 'as a participant' do
    let(:member) { participant }
    before { as_user member }

    it_behaves_like 'creating an availability'

    it 'allows me to reserve a slot', js: true do
      visit community_network_member_availabilities_path(community, network, availability.member)

      find('.fc-title').click
      within('.availability-mentor') { click_on 'Reserve' }
      within('table tbody tr:first-child') { click_on 'Reserve' }

      expect(page).to have_content 'You have successfully reserved the slot.'
    end
  end
end
