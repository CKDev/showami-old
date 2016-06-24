FactoryGirl.define do
  factory :event_log do
    tags "[Tag 1][Tag 2]"
    level "info"
    details "Information on the event that happened"
  end
end
