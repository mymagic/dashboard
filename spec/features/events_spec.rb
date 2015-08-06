require 'rails_helper'

RSpec.describe 'Events', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community) }
    given!(:network) { community.default_network }
    given!(:administrator) do
      create(:administrator, :confirmed, community: community)
    end
    given!(:staff) { create(:staff, :confirmed, community: community) }
    given!(:manager) { create(:member, :confirmed, community: community) }
    given!(:member) { create(:member, :confirmed, community: community) }

    shared_examples "viewing events" do
      context 'with an event' do
        given!(:event) do
          create(
            :event,
            creator: administrator,
            title: 'Great Event',
            description: 'Come visit!',
            location_type: 'skype',
            location_detail: 'great.event',
            network: network
          )
        end
        it 'shows the event data' do
          visit community_network_event_path(community, network, event)

          within '.page-header > h1' do
            expect(page).to have_content('Great Event')
          end

          expect(page).to have_content('Come visit!')
          expect(page).to have_content('Skype')
          expect(page).to have_content('great.event')

          visit community_network_path(community, network)
          within '.community-sidebar' do
            expect(page).to have_content('Upcoming Events')
            expect(page).to have_content('Great Event')
          end
        end
      end
    end

    shared_examples "rsvp events" do
      context 'with an event' do
        given!(:event) do
          create(
            :event,
            creator: administrator,
            title: 'Great Event',
            description: 'Come visit!',
            location_type: 'skype',
            location_detail: 'great.event',
            network: network
          )
        end
        it 'lets me rsvp' do
          visit community_network_event_path(community, network, event)
          within '.page-header' do
            click_link 'Join'
          end
          expect(page).to have_content('You RSVP\'d to the event as attending.')
        end
      end
    end

    shared_examples "creating events" do
      it 'creates an event' do
        visit community_admin_events_path(community)
        click_link 'Create new Event'

        fill_in 'Title', with: 'Boston Teaparty'
        fill_in 'Description', with: 'Free tea!'

        select 'Address', from: 'event_location_type'
        fill_in 'Detail', with: 'Bangkok'

        select '10', from: 'event_starts_at_4i'
        select '20', from: 'event_ends_at_4i'

        click_button 'Save Event'

        expect(page).to have_content 'Event was successfully created.'

        visit community_path(community)
        within '.activity-group' do
          expect(page).to have_content 'setup Boston Teaparty'
        end
      end
    end

    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "viewing events"
      it_behaves_like "rsvp events"
      it_behaves_like "creating events"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "viewing events"
      it_behaves_like "rsvp events"
      it_behaves_like "creating events"
    end

    context 'as manager' do
      background { as_user manager }
      it_behaves_like "viewing events"
      it_behaves_like "rsvp events"
    end

    context 'as member' do
      background { as_user member }
      it_behaves_like "viewing events"
      it_behaves_like "rsvp events"
    end
  end
end
