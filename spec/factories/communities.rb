FactoryGirl.define do
  factory :community do
    name { generate(:community_name) }
    slug { friendly_id }
    social_media_services { rand(10).times.map { generate(:service) } }
  end
end
