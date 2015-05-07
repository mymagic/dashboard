FactoryGirl.define do
  factory :discussion do
    title { generate(:title) }
    body { generate(:body) }
    author
    community { author.community }
  end
end
