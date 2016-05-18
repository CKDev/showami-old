FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@showami.com"
  end
end

FactoryGirl.define do
  factory :user do
    email
    password "asdfasdf"
    confirmed_at Time.zone.now.to_s
  end

  factory :admin, class: User do
    email
    password "asdfasdf"
    confirmed_at Time.zone.now.to_s
    admin true
  end

end
