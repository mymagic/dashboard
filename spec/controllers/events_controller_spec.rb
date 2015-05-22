require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe "GET #show" do
    let(:community) { create(:community) }
    let(:event) do
      create(:event, community: community)
    end
    let(:response) { get(:show, id: event, community_id: community) }
    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
  end
end
