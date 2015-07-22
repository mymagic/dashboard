FactoryGirl.define do
  factory :event do
    title { generate(:title) }
    network
    creator { create(:administrator, :confirmed, community: network.community) }
    location_detail 'Block 3730 APEC, 63000 Cyberjaya, Malaysia'
    location_type 'address'
    time_zone 'Bangkok'
    starts_at { 1.week.from_now }
    ends_at { starts_at + 3.hours }
    trait :with_description do
      description "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "\
                  "sed diam nonumy eirmod tempor invidunt ut labore et dolore "\
                  "magna aliquyam erat, sed diam voluptua."
    end
    trait :in_the_past do
      starts_at { 1.week.ago }
      ends_at { 1.week.ago + 3.hours }
    end
  end
end
