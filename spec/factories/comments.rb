FactoryGirl.define do
  factory :comment do
    body { generate(:body) }
    author
    discussion do
      create(:discussion,
             author: create(:member, :confirmed, community: author.community))
    end
  end
end
