require "rails_helper"

module Notification
  describe SMS do

    it "properly logs an SMS to a valid phone number" do
      to = "+15005550006"
      body = "SMS body"
      Rails.logger.expects(:info).once.with("Completed SMS showing notification to #{to}")
      Rails.logger.expects(:error).never
      Notification::SMS.new(to, body).send
    end

    it "properly logs an SMS to an invalid phone number" do
      to = "+15005550001"
      body = "SMS body"
      Rails.logger.expects(:info).never
      Rails.logger.expects(:error).once.with("Error: 21211 - The 'To' number +15005550001 is not a valid phone number.")
      Notification::SMS.new(to, body, true).send
    end

    it "prevents an empty to: number" do
      to = ""
      body = "SMS body"
      Rails.logger.expects(:info).never
      Rails.logger.expects(:error).once.with("Error: 21604 - A 'To' phone number is required.")
      Notification::SMS.new(to, body, true).send
    end
  end
end
