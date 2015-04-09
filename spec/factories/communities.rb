FactoryGirl.define do
  factory :community do
    name { generate(:community_name) }
    slug { friendly_id }

    trait :with_email do
      email { generate(:email) }
    end

    trait :with_social_media_services do
      social_media_services { rand(1..10).times.map { generate(:service) } }
    end
  end
end
