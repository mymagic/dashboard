require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
  authorized_members = %i(administrator mentor staff regular_member)
  let(:community) { create(:community) }
  let(:network) { community.default_network }

  describe "GET #show"do
    it { redirect_to [community, network] }
  end
end
