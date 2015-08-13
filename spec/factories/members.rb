FactoryGirl.define do
  factory :bare_member, class: Member do
    first_name { generate(:name) }
    last_name { generate(:name) }
    email
    time_zone 'Bangkok'
    password "password0"
    password_confirmation "password0"
    community
    trait :confirmed do
      after :create, &:confirm!
    end
    trait :invited do
      after :create, &:invite!
    end
  end

  factory :member, parent: :bare_member, aliases: [:participant, :author] do
    role ''
    before(:create) do |member|
      member.networks << member.community.default_network
      member.positions << build(:position, member: member)
    end
  end

  factory :administrator, parent: :bare_member do
    role 'administrator'
    before(:create) do |member|
      member.networks << member.community.default_network
    end
  end

  factory :mentor, parent: :bare_member do
    role 'mentor'
    before(:create) do |member|
      member.networks << member.community.default_network
    end
  end

  factory :staff, parent: :bare_member do
    role 'staff'
    before(:create) do |member|
      member.networks << member.community.default_network
    end
  end
end
