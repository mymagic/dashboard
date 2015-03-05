FactoryGirl.define do
  factory :position do
    name { generate(:name) }
  end
end
