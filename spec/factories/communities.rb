FactoryGirl.define do
  factory :community do
    transient do
      num_of_services 2
    end

    name { generate(:community_name) }
    slug { friendly_id }

    trait :with_email do
      email { generate(:email) }
    end

    trait :with_social_media_services do
      social_media_services { num_of_services.times.map { generate(:service) } }
    end
  end
end
