FactoryGirl.define do
  factory :message do
    sender { association(:member) }
    receiver { association(:member, community: sender.community) }
    body { generate(:message_body) }
  end
end
