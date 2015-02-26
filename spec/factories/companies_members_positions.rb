FactoryGirl.define do
  factory :companies_members_position, aliases: [:companies_position] do
    member
    company
    position
    trait :approved do
      approved true
    end
  end
end
