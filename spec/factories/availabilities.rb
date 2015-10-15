FactoryGirl.define do
  factory :availability do
    member
    start_time { Time.now }
    end_time { start_time + 120.minute }
    date { DateTime.now }
    time_zone 'Bangkok'
    location_type { Availability::LOCATION_TYPES.sample }
    location_detail 'MyMaGIC'
    wday { rand 0..6 }
    slot_duration { Availability::SLOT_DULATIONS.sample }
    details { generate(:body) }

    before(:create) do |availability|
      availability.networks << availability.member.community.default_network
    end

    trait :recurring do
      recurring true
    end
  end
end
