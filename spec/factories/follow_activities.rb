FactoryGirl.define do
  factory :follow_activity do
    owner { create(:member, :confirmed) }
    trait :follow_other_member do
      followable { create(:member, community: owner.community) }
    end
    trait :follow_discussion do
      followable {
        create(:discussion, author: create(:member, community: owner.community))
      }
    end
  end
end
