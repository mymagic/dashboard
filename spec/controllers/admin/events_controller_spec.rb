require 'rails_helper'

RSpec.describe Admin::EventsController, type: :controller do
  let(:community) { create(:community) }
  let(:network) { community.default_network }
  let(:event) { create(:event, network: network) }

  describe "GET #index" do
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe "GET #edit" do
    let(:response) { get(:edit, id: event, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe 'PATCH #update' do
    let(:response) do
      patch(
        :update,
        id: event,
        community_id: community,
        event: { title: 'New Event Title' }
      )
    end
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe 'DELETE #destroy' do
    let(:response) { delete(:destroy, id: event, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe "PUT #create" do
    let(:event_required_attributes) do
      {
        title: 'An Event',
        location_detail: 'Bangkok, Thailand',
        location_type: 'Address',
        time_zone: 'Bangkok',
        starts_at: 1.week.from_now,
        ends_at: 1.week.from_now + 3.hours
      }
    end

    def create_new_event(attributes = {})
      put(
        :create,
        community_id: community,
        event: (event_required_attributes).merge(attributes)
      )
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { create_new_event }
    end
  end
end
