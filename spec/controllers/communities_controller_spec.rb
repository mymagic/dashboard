require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
  authorized_members = %i(administrator mentor staff regular_member)
  let(:community) { create(:community) }

  describe "GET #show" do
    it_behaves_like 'accessible by', *authorized_members do
      let(:response) { get(:show, id: community) }
    end
  end
end
