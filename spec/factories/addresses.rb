FactoryGirl.define do
  factory :address do
    line1 "600 S Broadway"
    line2 "Unit 200"
    city "Denver"
    state "CO"
    zip "80209"
  end

  factory :vail_address, class: Address do
    line1 "100 Bridge Street"
    line2 ""
    city "Vail"
    state "CO"
    zip "81657"
  end
end
