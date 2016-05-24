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

    factory :user_with_valid_profile do
      after(:create) do |user|
        user.profile.first_name = "Alejandro"
        user.profile.last_name = "Brinkster"
        user.profile.phone1 = "555 123 1234 x 123"
        user.profile.phone2 = "555 987 1234 x 456"
        user.profile.company = "Showing Services, LLC"
        user.profile.agent_id = "1234 1234"
        user.profile.agent_type = 2
        user.profile.save
      end
    end
  end

  factory :admin, class: User do
    email
    password "asdfasdf"
    confirmed_at Time.zone.now.to_s
    admin true
  end

end
