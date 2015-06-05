FactoryGirl.define do
  factory :rsvp_activity do
    owner { create(:member, :confirmed) }
    event { create(:event, community: owner.community) }
    data { { "state" => Rsvp::STATES.sample } }
  end
end
