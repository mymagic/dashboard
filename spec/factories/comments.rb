FactoryGirl.define do
  factory :comment do
    body { generate(:body) }
    author
    discussion do
      create(:discussion,
             author: create(:member, :confirmed, community: author.community),
             network: author.community.networks.first )
    end
  end
end
