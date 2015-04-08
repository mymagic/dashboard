FactoryGirl.define do
  factory :social_media_link do
    community { attachable.community }
    service { attachable.community.social_media_services.sample }
    handle  { generate(:handle) }

    trait :member do
      attachable { association(:member) }
    end

    trait :company do
      attachable { association(:company) }
    end
  end
end
