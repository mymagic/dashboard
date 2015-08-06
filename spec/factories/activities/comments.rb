FactoryGirl.define do
  factory :comment_activity, class: Activity::Commenting do
    owner { create(:member, :confirmed) }
    discussion {
      create(:discussion,
             author: create(:member, community: owner.community),
             network: owner.community.default_network)
    }
    comment { create(:comment, discussion: discussion, author: owner) }
  end
end
