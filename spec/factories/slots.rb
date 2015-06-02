FactoryGirl.define do
  factory :slot do
    member
    availability
    start_time { Time.now }
    end_time { start_time + availability.slot_duration * 60 }
  end
end
