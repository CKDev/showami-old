FactoryGirl.define do
  factory :profile do
    first_name "Alejandro"
    last_name "Brinkster"
    phone1 "555 123 1234"
    phone2 "555 987 1234"
    company "Showing Services, LLC"
    agent_id "1234 1234"
    agent_type 2
    avatar { fixture_file_upload(Rails.root.join("spec", "fixtures", "avatar.png"), "image/png") }
    geo_box "(-104.682, 39.822), (-105.358, 39.427)"
    cc_token "valid_cc_token"
    bank_token "valid_bank_token"
  end

end
