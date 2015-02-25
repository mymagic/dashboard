FactoryGirl.define do
  factory :member, aliases: [:participant] do
    first_name
    last_name
    email
    time_zone 'Bangkok'
    password "password0"
    password_confirmation "password0"
    trait :confirmed do
      after :create, &:confirm!
    end
  end

  factory :administrator, parent: :member do
    role 'administrator'
  end

  factory :mentor, parent: :member do
    role 'mentor'
  end

  factory :staff, parent: :member do
    role 'staff'
  end
end
