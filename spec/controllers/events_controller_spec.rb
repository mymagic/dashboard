require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:community) { create(:community) }
  let(:network) { community.default_network }
  let(:event) do
    create(:event, network: network)
  end
  describe "GET #show" do
    let(:response) do
      get(:show, id: event, community_id: community, network_id: network)
    end
    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
  end

  describe "PATCH #rsvp" do
    let(:response) do
      patch(
        :rsvp,
        id: event,
        community_id: community,
        network_id: network,
        rsvp: { state: 'attending' })
    end
    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
  end
end
