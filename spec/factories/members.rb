FactoryGirl.define do
  factory :member, aliases: [:mentor, :participant] do
    first_name 'Harry'
    last_name 'Houdini'
    email
    time_zone 'Bangkok'
    password 'abracadabra'
    password_confirmation 'abracadabra'
  end

  factory :administrator, class: Member do
    first_name 'Demigod'
    last_name 'Caesar'
    email
    time_zone 'Rome'
    password 'NeverTrustBrutus'
    password_confirmation 'NeverTrustBrutus'
    role 'administrator'
  end
end
