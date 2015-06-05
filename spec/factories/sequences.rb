FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :name do |n|
    "Name#{ n }"
  end

  sequence :tag_name do |n|
    "Tag#{ n }"
  end

  sequence :title do |n|
    "This is title #{ n }"
  end

  sequence :body do |n|
    "This is body #{ n }"
  end

  sequence :position_name do |n|
    "PositionName#{ n }"
  end

  sequence :service do |n|
    "service-#{ n }"
  end

  sequence :community_name do |n|
    "community-#{ n }"
  end

  sequence :url do |n|
    "http://website#{ n }.com"
  end

  sequence :message_body do |n|
    "message-body-#{ n }"
  end
end
