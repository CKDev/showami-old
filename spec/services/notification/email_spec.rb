require "rails_helper"

module Notification
  describe Email do

    it "properly sends an credit card failure email notification to all admins in the system" do
      @admin1 = FactoryGirl.create(:user_with_valid_profile, admin: true)
      @admin2 = FactoryGirl.create(:user_with_valid_profile, admin: true)
      @admin3 = FactoryGirl.create(:user_with_valid_profile, admin: false)
      showing_details = "Showing details"
      error = "CC failed because..."
      success_object = stub(deliver_later: true)

      AdminMailer.expects(:cc_failure).once.with(@admin1, error, showing_details).returns(success_object)
      AdminMailer.expects(:cc_failure).once.with(@admin2, error, showing_details).returns(success_object)
      AdminMailer.expects(:cc_failure).once.with(@admin3, error, showing_details).never
      success_object.expects(:deliver_later).once
      Notification::Email.notify_admins_cc_failure(error, showing_details)
    end

  end
end
