FactoryGirl.define do
  factory :showing do
    showing_date Time.zone.now
    mls "abc123"
    notes "notes about the showing"
    address
  end
end
