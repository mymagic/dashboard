FactoryGirl.define do
  factory :availability do
    member
    time { Time.now }
    date { DateTime.now }
    time_zone 'Bangkok'
    location_type { Availability::LOCATION_TYPES.sample }
    location_detail 'MyMaGIC'
    wday { rand 0..6 }
    duration 120
    slot_duration { Availability::SLOT_DULATIONS.sample }
    details { generate(:body) }
  end
end
