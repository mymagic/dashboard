FactoryGirl.define do
  factory :position do
    name { generate(:position_name) }
    community
  end
end
