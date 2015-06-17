FactoryGirl.define do
  factory :social_media_link do
    community { association(:community) }
    service { attachable.community.social_media_services.sample }
    url  { generate(:url) }

    trait :member do
      attachable { association(:member, community: community) }
    end

    trait :company do
      attachable { association(:company, community: community) }
    end
  end
end
