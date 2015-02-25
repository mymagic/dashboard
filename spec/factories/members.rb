FactoryGirl.define do
  factory :member, aliases: [:participant] do
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

  factory :mentor, class: Member do
    first_name 'Isokratos'
    last_name 'Socrates'
    email
    time_zone 'Athen'
    password 'NoOneDesiresEvil'
    password_confirmation 'NoOneDesiresEvil'
    role 'mentor'
  end

  factory :staff, class: Member do
    first_name 'Johann'
    last_name 'Faust'
    email
    time_zone 'Berlin'
    password 'ZwarWeißIchVielDochMöchtIchAllesWissen'
    password_confirmation 'ZwarWeißIchVielDochMöchtIchAllesWissen'
    role 'staff'
  end
end
