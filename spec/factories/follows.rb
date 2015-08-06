FactoryGirl.define do
  factory :follow do
    member
    trait :discussion do
      followable { create(:discussion, network: member.default_network) }
    end
    trait :member do
      followable { create(:member, network: member.default_network) }
    end
  end
end
