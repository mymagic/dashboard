FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :name do |n|
    "Name#{ n }"
  end

  sequence :position_name do |n|
    "PositionName#{ n }"
  end

  sequence :service do |n|
    "service-#{ n }"
  end

  sequence :handle do |n|
    "handle-#{ n }"
  end

  sequence :community_name do |n|
    "community-#{ n }"
  end
end
