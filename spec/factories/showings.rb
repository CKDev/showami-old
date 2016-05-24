FactoryGirl.define do
  factory :showing do
    showing_at Time.zone.now + 3.hours
    mls "abc123"
    notes "notes about the showing"
    address
  end
end
