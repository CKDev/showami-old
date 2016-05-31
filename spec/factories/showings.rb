FactoryGirl.define do
  factory :showing do
    showing_at Time.zone.now + 3.hours
    mls "abc123"
    notes "notes about the showing"
    buyer_name "Andre"
    buyer_phone "7776665555"
    buyer_type "individual"
    address
  end
end
