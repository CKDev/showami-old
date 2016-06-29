require "rails_helper"

describe EventLog do

  context "#single_line" do

    it "can print itself in a readable string format" do
      Timecop.freeze(Time.zone.local(2016, 6, 1, 12, 0, 0)) do
        event_log = FactoryGirl.create(:event_log)
        expect(event_log.to_s).to eq "Jun 01, 2016 12:00 PM \n Information on the event that happened"
      end
    end

  end

end
