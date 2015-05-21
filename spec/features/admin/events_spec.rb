require 'rails_helper'

RSpec.describe 'Admin/Events', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community, :with_social_media_services) }
    given(:administrator) { create(:administrator, :confirmed, community: community) }
    given(:staff) { create(:staff, :confirmed, community: community) }
    given(:starts_at) { 1.month.from_now.midnight }
    given(:ends_at) { starts_at + 3.hours }

    shared_examples "managing events" do
      it "creates a new event" do
        visit community_admin_events_path(community)
        click_link "Create new Event"

        # General Information
        fill_in 'Title', with: 'Greatest Event of all time'
        fill_in 'Description', with: 'Come to our great Event!'

        # Location and time
        select 'Address', from: 'Location type'
        fill_in 'Location detail', with: 'Private Island'
        %i(starts_at ends_at).each do |datetime|
          select send(datetime).strftime('%Y'), from: "event_#{ datetime }_1i"
          select send(datetime).strftime('%B'), from: "event_#{ datetime }_2i"
          select send(datetime).strftime('%-d'), from: "event_#{ datetime }_3i"
          select send(datetime).strftime('%H'), from: "event_#{ datetime }_4i"
          select send(datetime).strftime('%M'), from: "event_#{ datetime }_5i"
        end
        select '(GMT-10:00) Hawaii', from: 'Time zone'

        click_button 'Save'

        expect(page).to have_content('Event was successfully created.')
      end

      context 'with an event' do
        given!(:event) do
          create(
            :event,
            creator: administrator,
            starts_at: starts_at,
            title: 'Great Event'
          )
        end
        it 'edits the event' do
          visit community_admin_events_path(community)

          within '#upcoming-events' do
            expect(page).to_not have_content('Better Event')
            expect(page).to have_content("Great Event")
            click_link 'Edit'
          end

          fill_in 'Title', with: 'Better Event'
          click_button 'Save'

          expect(page).to have_content('Event was successfully updated.')

          within '#upcoming-events' do
            expect(page).to have_content('Better Event')
            expect(page).to_not have_content("Great Event")
          end
        end
        it 'destroys the event' do
          visit community_admin_events_path(community)

          within '#upcoming-events' do
            expect(page).to have_content("Great Event")
            click_link 'Edit'
          end

          click_link 'Delete this Event'

          expect(page).to have_content('Event was successfully deleted.')

          within '#upcoming-events' do
            expect(page).to_not have_content("Great Event")
          end
        end
      end
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "managing events"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "managing events"
    end
  end
end
