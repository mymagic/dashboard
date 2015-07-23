FactoryGirl.define do
  factory :follow do
    member
    trait :discussion do
      followable { create(:discussion, network: member.networks.first) }
    end
    trait :member do
      followable { create(:member, network: member.networks.first) }
    end
  end
end
