require 'rails_helper'

RSpec.describe 'Events', type: :feature, js: false do
  feature "Administration" do
    given!(:community) { create(:community, :with_social_media_services) }
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
            location_type: 'Skype',
            location_detail: 'great.event'
          )
        end
        it 'shows the event data' do
          visit community_event_path(community, event)

          within '.page-header > h1' do
            expect(page).to have_content('Great Event')
          end

          expect(page).to have_content('Come visit!')
          expect(page).to have_content('Skype')
          expect(page).to have_content('great.event')
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
            location_type: 'Skype',
            location_detail: 'great.event'
          )
        end
        it 'lets me rsvp' do
          visit community_event_path(community, event)
          within '.page-header' do
            click_link 'Join'
          end
          expect(page).to have_content('You RSVP\'d to the event as attending.')
        end
      end
    end


    context 'as administrator' do
      background { as_user administrator }
      it_behaves_like "viewing events"
      it_behaves_like "rsvp events"
    end

    context 'as staff' do
      background { as_user staff }
      it_behaves_like "viewing events"
      it_behaves_like "rsvp events"
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
