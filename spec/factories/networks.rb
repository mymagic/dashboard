FactoryGirl.define do
  factory :network do
    name { generate(:network_name) }
    slug { friendly_id }
  end
end
