FactoryGirl.define do
  factory :follow_activity, class: Activity::Following do
    owner { create(:member, :confirmed) }
    network { owner.default_network }
    trait :follow_other_member do
      followable { create(:member, community: owner.community) }
    end
    trait :follow_discussion do
      followable {
        create(:discussion,
               author: create(:member, community: owner.community),
               network: owner.default_network)
      }
    end
  end
end
