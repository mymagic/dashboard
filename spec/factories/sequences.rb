FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :first_name do |n|
    "Firstname#{ n }"
  end

  sequence :last_name do |n|
    "Lastname#{ n }"
  end
end
