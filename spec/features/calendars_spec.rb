require 'rails_helper'

RSpec.describe 'Calendars', type: :feature, js: true do
  let!(:event) do
    create(:event,
      title: 'Great Event',
      starts_at: DateTime.now.in_time_zone('Bangkok')
    )
  end
  let!(:network) { event.default_network }
  let!(:community) { network.community }
  let(:date) { Date.today }
  let(:time) { Time.utc(2000, 1, 1, 1, 0, 0).in_time_zone('Bangkok') }

  shared_examples_for 'viewable mentor availabilities' do
    let(:mentor) do
      create(:member, :confirmed, role: 'mentor', community: community)
    end
    let(:mentor2) do
      create(:member, :confirmed, role: 'mentor', community: community)
    end
    let!(:availability) { create(:availability, member: mentor,
      start_time: time, end_time: time + 2.hours, slot_duration: 30) }
    let!(:availability2) do
      create(:availability, member: mentor, start_time: time - 1.hour,
        end_time: time + 1.hour, slot_duration: 30)
    end
    let!(:availability3) do
      create(:availability, member: mentor2, start_time: time + 2.hours,
        end_time: time + 3.hour, slot_duration: 30)
    end

    it 'see all availabilities inside community' do
      visit community_network_calendar_path(community, network)

      expect(page).to have_selector '.fc-event-container.availability',
        count: 1
      find('.fc-event-container.availability').hover
      expect(page).to have_selector '.calendar-popover'
      available_date = availability.date.strftime("%b %d, %Y")
      expect(page).to have_content "Office Hours on #{available_date}"

      expect(page).to have_selector '.office-hours-details', count: 2
      expect(page).to have_content "#{mentor.full_name}"
      expect(page).to have_content "#{mentor2.full_name}"

      within find(".availability-mentor", text: mentor.full_name) do
        expect(page).to have_content "07:00 - 09:00 #{availability2.details}"
        expect(page).to have_content "08:00 - 10:00 #{availability.details}"
      end

      within find(".availability-mentor", text: mentor2.full_name) do
        expect(page).to have_content "10:00 - 11:00 #{availability3.details}"
      end

      expect(page).to have_selector '.fc-event-container.availability',
        count: 1
      find('.fc-event-container.availability').hover
      expect(page).to have_selector '.calendar-popover'
      find(".availability-mentor", text: mentor.full_name).click
      expect(page).to have_selector'#member__sidebar'
      expect(current_url).to eq community_network_member_availability_slots_url(
        community, network, mentor, date.year, date.month, date.day,
        host: 'http://localhost', port: 3001
      )
    end
  end

  shared_examples_for 'viewable events' do
    let!(:other_event) { create(:event) }
    let!(:external_event) do
      create(:external_event,
        creator: event.creator,
        starts_at: DateTime.now.in_time_zone('Bangkok')
      )
    end

    it 'see all events inside community' do
      visit community_network_calendar_path(community, network)
      expect(page).to have_selector '.community-event', count: 1
      expect(page).to have_selector '.fc-title', text: event.title
      expect(page).not_to have_selector '.fc-title', text: other_event.title

      expect(page).to have_selector '.external-event', count: 1
      expect(page).to have_selector '.fc-title', text: external_event.title

      find('.fc-event-container.community-event').hover
      expect(page).to have_selector '.calendar-popover'
      date = event.starts_at.strftime("%b %d, %Y")
      expect(page).to have_content "Events on #{date}"

      href = community_network_event_path(community, network, event.id)
      href2 = community_network_event_path(community, network, external_event.id)

      time = external_event.starts_at.strftime('%l:%M%P')

      within '.popover-content' do
        expect(page).to have_selector ".community-events-details[href='#{href}']",
          text: "#{event.title}#{event.starts_at.strftime('%l:%M%P')}"

        expect(page).to have_selector ".external-events-details[href='#{href2}']",
          text: "#{external_event.title}#{time}"
      end
    end
  end

  describe 'As administrator' do
    let(:administrator) { event.creator }

    before { as_user administrator }
    it_behaves_like 'viewable mentor availabilities'
    # it_behaves_like 'viewable events'
  end

  describe 'As staff' do
    let(:staff) do
      create(:member, :confirmed, role: 'staff', community: community)
    end

    before { as_user staff }
    it_behaves_like 'viewable mentor availabilities'
    # it_behaves_like 'viewable events'
  end

  describe 'As mentor' do
    let(:mentor) do
      create(:member, :confirmed, role: 'mentor', community: community)
    end

    before { as_user mentor }
    it_behaves_like 'viewable mentor availabilities'
    # it_behaves_like 'viewable events'
  end
end
