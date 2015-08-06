FactoryGirl.define do
  factory :rsvp_activity, class: Activity::Rsvping do
    owner { create(:member, :confirmed) }
    event { create(:event, network: owner.default_network) }
    data { { "state" => Rsvp::STATES.sample } }
  end
end
