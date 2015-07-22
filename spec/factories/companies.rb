FactoryGirl.define do
  factory :company do
    name { generate(:name) }
    community
    before(:create) do |company|
      company.networks << company.community.networks.first
    end
  end
end
