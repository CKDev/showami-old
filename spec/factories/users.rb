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
        user.profile.phone1 = "555 123 1234"
        user.profile.phone2 = "555 987 1234"
        user.profile.company = "Showing Services, LLC"
        user.profile.agent_id = "1234 1234"
        user.profile.agent_type = 2
        user.profile.avatar = fixture_file_upload(Rails.root.join("spec", "fixtures", "avatar.png"), "image/png")
        user.profile.geo_box = "(-104.682, 39.822), (-105.358, 39.427)"
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
