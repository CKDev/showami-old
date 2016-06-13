require "rails_helper"

describe Constants do

  it "should return the expected date format for datetime_format" do
    Timecop.freeze do
      t = Time.zone.local(2016, 9, 1, 10, 5, 0)
      expect(t.strftime(Constants.datetime_format)).to eq "Sep 01, 2016 10:05 AM"
    end
  end

  it "should return the expected date format for month_format" do
    Timecop.freeze do
      t = Time.zone.local(2016, 9, 1, 10, 5, 0)
      expect(t.strftime(Constants.month_format)).to eq "Sep"
    end
  end

  it "should return the expected date format for day_format" do
    Timecop.freeze do
      t = Time.zone.local(2016, 9, 1, 10, 5, 0)
      expect(t.strftime(Constants.day_format)).to eq "01"
    end
  end

  it "should return the expected date format for time_format" do
    Timecop.freeze do
      t = Time.zone.local(2016, 9, 1, 10, 5, 0)
      expect(t.strftime(Constants.time_format)).to eq "10:05 AM"
    end
  end

end
