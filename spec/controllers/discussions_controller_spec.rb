require 'rails_helper'

RSpec.describe DiscussionsController, type: :controller do
  let(:community) { create(:community) }

  describe "GET #index" do
    let(:response) { get(:index, community_id: community) }

    it_behaves_like(
      "accessible by", :administrator, :mentor, :staff, :regular_member
    )
    describe 'assigning discussions' do
      let!(:member) { create(:member, :confirmed, community: community) }
      let!(:discussion_one) do
        create(:discussion, author: create(:member, community: community))
      end
      let!(:discussion_two) do
        create(:discussion, author: create(:member, community: community))
      end
      let!(:discussion_other_community) do
        create(:discussion, author: create(:member))
      end
      before do
        login(member)
        get :index, community_id: community
      end
      it 'assigns the correct discussions' do
        expect(assigns(:discussions)).
          to contain_exactly(discussion_one, discussion_two)
      end
    end
  end
end
