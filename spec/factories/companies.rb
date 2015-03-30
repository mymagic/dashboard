FactoryGirl.define do
  factory :company do
    name { generate(:name) }
    community
  end
end
