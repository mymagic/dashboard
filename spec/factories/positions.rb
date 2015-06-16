FactoryGirl.define do
  factory :position do
    member
    company { create(:company, community: member.community) }
  end
end
