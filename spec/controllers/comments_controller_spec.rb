require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  authorized_members = %i(administrator mentor staff regular_member)
  let(:community) { create(:community) }
  let(:network) { community.default_network }
  let(:discussion) do
    create(:discussion,
           author: create(:author, :confirmed, community: community),
           network: network)
  end

  describe 'POST #create' do
    let(:comment_required_attributes) do
      { body: 'A body' }
    end
    def create_new_comment(attributes = {})
      post(
        :create,
        community_id: community,
        network_id: network,
        discussion_id: discussion,
        comment: (comment_required_attributes).merge(attributes)
      )
    end
    it_behaves_like "accessible by", *authorized_members do
      let(:response) { create_new_comment }
    end
  end

  describe 'DELETE #destroy' do
    let!(:comment) do
      create(:comment, author: create(:member, community: community))
    end
    it_behaves_like "accessible by", :administrator do
      let(:response) do
        delete(:destroy,
               community_id: community,
               network_id: network,
               discussion_id: comment.discussion,
               id: comment)
      end
    end
  end
end
