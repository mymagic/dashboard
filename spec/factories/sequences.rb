FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :name do |n|
    "Name#{ n }"
  end

  sequence :community_name do |n|
    "community-#{ n }"
  end
end
