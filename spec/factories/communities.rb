FactoryGirl.define do
  factory :community do
    name { generate(:community_name) }
    email { generate(:email) }
    slug { friendly_id }
    social_media_services { rand(1..10).times.map { generate(:service) } }
  end
end
