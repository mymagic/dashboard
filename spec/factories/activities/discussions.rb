FactoryGirl.define do
  factory :discussion_activity, class: Activity::Discussing do
    owner { create(:member, :confirmed) }
    discussion { create(:discussion, author: owner, network: owner.networks.first) }
  end
end
