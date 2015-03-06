FactoryGirl.define do
  factory :community do
    name { Faker::Company.name }
    slug { friendly_id }
  end
end
