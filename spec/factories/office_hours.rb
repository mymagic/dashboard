FactoryGirl.define do
  factory :office_hour do
    mentor
    community
    time { 1.week.from_now }
    time_zone 'Bangkok'
    trait :booked do
      participant
    end
  end
end
