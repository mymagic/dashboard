FactoryGirl.define do
  factory :community do
    name { generate(:community_name) }
    slug { friendly_id }
  end
end
