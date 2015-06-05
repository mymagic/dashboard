require 'rails_helper'

RSpec.describe Activity, type: :model do
  context 'validations' do
    subject { Activity.new }

    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:community) }
    it { is_expected.to validate_presence_of(:resource) }
  end

  describe '.for' do
    let(:community) { create(:community) }
    let(:member) { create(:member, community: community) }
    let(:alice) { create(:member, community: community) }
    let(:bob) { create(:member, community: community) }
    let(:followed_discussion) { create(:discussion, community: community) }
    let(:other_discussion) { create(:discussion, community: community) }

    # FollowActivities
    let(:alice_following_a_member) do
      create(:follow_activity, :follow_other_member, owner: alice)
    end
    let(:alice_following_a_discussion) do
      create(:follow_activity, :follow_discussion, owner: alice)
    end
    let(:bob_following_a_member) do
      create(:follow_activity, :follow_other_member, owner: bob)
    end
    let(:bob_following_a_discussion) do
      create(:follow_activity, :follow_discussion, owner: bob)
    end

    # DiscussionActivities
    let(:alice_creating_a_discussion) do
      create(:discussion_activity, owner: alice)
    end
    let(:bob_creating_a_discussion) { create(:discussion_activity, owner: bob) }

    # CommentActivities
    let(:alice_creating_a_comment) { create(:comment_activity, owner: alice) }
    let(:bob_creating_a_comment) { create(:comment_activity, owner: bob) }
    let(:commenting_on_followed_discussion) do
      create(:comment_activity, discussion: followed_discussion)
    end
    let(:commenting_on_other_discussion) do
      create(:comment_activity, discussion: other_discussion)
    end

    # RsvpActivities
    let(:alice_rsvping_to_an_event) { create(:rsvp_activity, owner: alice) }
    let(:bob_rsvping_to_an_event) { create(:rsvp_activity, owner: bob) }

    let!(:activities_of_interest) do
      [
        alice_following_a_member,
        alice_following_a_discussion,
        alice_creating_a_discussion,
        alice_creating_a_comment,
        commenting_on_followed_discussion,
        alice_rsvping_to_an_event
      ]
    end
    let!(:other_activities) do
      [
        bob_following_a_member,
        bob_following_a_discussion,
        bob_creating_a_discussion,
        bob_creating_a_comment,
        commenting_on_other_discussion,
        bob_rsvping_to_an_event
      ]
    end

    before do
      member.followed_members << alice
      member.followed_discussions << followed_discussion
    end
    subject { Activity.for(member) }

    it { is_expected.to include(*activities_of_interest) }
    it { is_expected.to_not include(*other_activities)   }
  end
end
