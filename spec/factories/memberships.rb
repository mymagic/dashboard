FactoryGirl.define do
  factory :membership do
    member
    network { create(:network, community: member.community) }
  end
end
