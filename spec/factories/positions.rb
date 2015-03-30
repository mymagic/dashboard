FactoryGirl.define do
  factory :position do
    name { generate(:name) }
    community
  end
end
