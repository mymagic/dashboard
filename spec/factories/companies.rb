FactoryGirl.define do
  factory :company do
    name { generate(:name) }
  end
end
