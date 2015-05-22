FactoryGirl.define do
  factory :rsvp do
    event
    member { create(:member, :confirmed, community: event.community) }
    state 'attending'
  end
end
