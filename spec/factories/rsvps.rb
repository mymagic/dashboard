FactoryGirl.define do
  factory :rsvp do
    event
    member { create(:member, :confirmed, community: event.network.community) }
    state 'attending'
  end
end
