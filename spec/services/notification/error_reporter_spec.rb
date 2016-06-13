require "rails_helper"

module Notification
  describe ErrorReporter do

    it "properly sends the error off to Rollbar" do
      error = StandardError.new "A notification to Rollbar"
      Rollbar.expects(:error).once.with(instance_of(StandardError))
      Notification::ErrorReporter.send(error)
    end

  end
end
