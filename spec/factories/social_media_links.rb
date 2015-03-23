FactoryGirl.define do
  factory :social_media_link do
    service { SocialMediaLink::SERVICES.sample }
    handle  { Faker::Internet.user_name }

    trait :member do
      attachable { association(:member) }
    end

    trait :company do
      attachable { association(:company) }
    end
  end
end
