require 'rails_helper'

RSpec.describe DiscussionsController, type: :controller do
  authorized_members = %i(administrator mentor staff regular_member)
  let(:community) { create(:community) }
  let(:network) { community.default_network }

  describe "GET #index" do
    it_behaves_like 'accessible by', *authorized_members do
      let(:response) { get(:index, community_id: community, network_id: network) }
    end

    describe 'retrieving discussions' do
      let!(:member) { create(:member, :confirmed, community: community) }
      let!(:discussion_one) do
        create(:discussion,
               author: create(:member, community: community),
               network: network)
      end
      let!(:discussion_two) do
        create(:discussion,
               author: create(:member, community: community),
               network: network)
      end
      let!(:discussion_other_community) do
        other_network = create(:network)
        create(:discussion, author: create(:member), network: other_network)
      end
      let!(:discussion_tag) do
        discussion_one.add_tag('tagging')
      end
      before { login(member) }
      context 'without tags' do
        before { get :index, community_id: community, network_id: network }
        it 'retrieves the correct discussions' do
          expect(assigns(:discussions)).
            to contain_exactly(discussion_one, discussion_two)
        end
      end
      context 'with tags' do
        before do
          get :index, community_id: community, network_id: network, tag_id: discussion_tag
        end
        it 'retrieves the correct discussions' do
          expect(assigns(:discussions)).
            to contain_exactly(discussion_one)
        end
      end
    end
  end

  describe 'POST #create' do
    let(:discussion_required_attributes) do
      { title: 'A title', body: 'A body' }
    end
    def create_new_discussion(attributes = {})
      post(
        :create,
        community_id: community,
        network_id: network,
        discussion: (discussion_required_attributes).merge(attributes)
      )
    end
    it_behaves_like "accessible by", *authorized_members do
      let(:response) { create_new_discussion }
    end
  end

  describe 'DELETE #destroy' do
    let!(:discussion) do
      create(:discussion,
             author: create(:member, community: community),
             network: network)
    end
    it_behaves_like "accessible by", :administrator do
      let(:response) do
        delete(:destroy, community_id: community, network_id: network, id: discussion)
      end
    end
  end
end
