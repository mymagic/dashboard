FactoryGirl.define do
  factory :follow do
    member
    trait :discussion do
      followable { create(:discussion, community: member.community) }
    end
    trait :member do
      followable { create(:member, community: member.community) }
    end
  end
end
