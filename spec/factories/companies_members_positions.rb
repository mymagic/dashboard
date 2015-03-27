FactoryGirl.define do
  factory :companies_members_position, aliases: [:companies_position] do
    company
    position
    member { create(:member, community: position.community) }
    trait :approved do
      approved true
    end
    trait :managable do
      can_manage_company true
    end
  end
end
