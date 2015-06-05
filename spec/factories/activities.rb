FactoryGirl.define do
  factory :activity do
    owner { create(:member, :confirmed) }
  end
end
