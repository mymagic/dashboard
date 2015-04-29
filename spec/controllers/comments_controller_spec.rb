require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  authorized_members = %i(administrator mentor staff regular_member)
  let(:community) { create(:community) }
  let(:discussion) do
    create(:discussion,
           author: create(:author, :confirmed, community: community))
  end

  describe 'POST #create' do
    let(:comment_required_attributes) do
      { body: 'A body' }
    end
    def create_new_comment(attributes = {})
      post(
        :create,
        community_id: community,
        discussion_id: discussion,
        comment: (comment_required_attributes).merge(attributes)
      )
    end
    it_behaves_like "accessible by", *authorized_members do
      let(:response) { create_new_comment }
    end
  end
end
