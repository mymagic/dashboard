FactoryGirl.define do
  factory :discussion_activity do
    owner { create(:member, :confirmed) }
    discussion { create(:discussion, author: owner) }
  end
end
