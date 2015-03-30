require 'rails_helper'

RSpec.describe 'OfficeHours', type: :feature, js: false do
  let!(:community) { create(:community) }
  let!(:administrator) { create(:administrator, :confirmed, community: community) }
  let!(:member) { create(:member, :confirmed, community: community) }
  let!(:office_hour) { create(:office_hour, community: community, mentor: administrator) }

  before { as_user administrator }

  scenario 'creating new office hour' do
    visit community_office_hours_path(community)
    select '2015', from: 'office_hour_time_1i'
    select 'March', from: 'office_hour_time_2i'
    select '27', from: 'office_hour_time_3i'
    select '10', from: 'office_hour_time_4i'
    select '53', from: 'office_hour_time_5i'
    click_on 'Submit'

    expect(page).to have_content('2015-03-27 10:53:00')
  end

  scenario 'deleting an office hour' do
    visit community_office_hours_path(community)

    within 'tbody tr:last-child' do
      click_on 'Delete'
    end

    expect(page).to_not have_content(office_hour.time_in_zone)
  end

  context 'with participant' do
    let!(:office_hour) { create(:office_hour, community: community) }

    scenario 'booking an office hour' do
      visit community_office_hours_path(community)

      within 'tbody tr:first-child' do
        click_on 'Book'
      end

      expect(page).to_not have_content('Available')
    end
  end

  context 'as available' do
    let!(:office_hour) { create(:office_hour, community: community, mentor: administrator) }

    scenario 'viewing office hours' do
      visit community_office_hours_path(community)

      within 'tbody tr:first-child' do
        expect(page).to have_content('Available')
        expect(page).to have_content(office_hour.time_in_zone)
        expect(page).to have_content(office_hour.mentor_full_name)
        expect(page).to have_content(office_hour.participant_full_name)
      end
    end
  end

  context 'as booked' do
    let!(:office_hour) { create(:office_hour, :booked, community: community, mentor: administrator, participant: member) }

    scenario 'viewing office hours' do
      visit community_office_hours_path(community)

      within 'tbody tr:first-child' do
        expect(page).to have_content('Booked')
        expect(page).to have_content(office_hour.time_in_zone)
        expect(page).to have_content(office_hour.mentor_full_name)
        expect(page).to have_content(office_hour.participant_full_name)
      end
    end
  end
end
