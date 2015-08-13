FactoryGirl.define do
  factory :tag do
    transient do
      num_of_taggings 2
    end

    name { generate(:tag_name) }
    network
    trait :discussion_tag do
      type { 'DiscussionTag' }
    end
    trait :with_taggings do
      after(:create) do |tag, evaluator|
        evaluator.num_of_taggings.times do
          create(:discussion_tagging, tag: tag)
        end
      end
    end
  end
end
