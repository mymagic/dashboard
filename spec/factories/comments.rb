FactoryGirl.define do
  factory :comment do
    body { generate(:body) }
    author
    discussion do
      create(:discussion,
             author: create(:member, :confirmed, community: author.community),
             network: author.community.default_network )
    end
  end
end
