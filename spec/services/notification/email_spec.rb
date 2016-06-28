require "rails_helper"

module Notification
  describe Email do

    it "properly sends an email notification to all admins in the system" do
      @admin1 = FactoryGirl.create(:user_with_valid_profile, admin: true)
      @admin2 = FactoryGirl.create(:user_with_valid_profile, admin: true)
      @admin3 = FactoryGirl.create(:user_with_valid_profile, admin: false)
      subject = "The Subject of the Email"
      body = "Email body"
      success_object = stub(deliver_later: true)

      AdminMailer.expects(:email).once.with(@admin1, subject, body).returns(success_object)
      AdminMailer.expects(:email).once.with(@admin2, subject, body).returns(success_object)
      AdminMailer.expects(:email).once.with(@admin3, subject, body).never
      success_object.expects(:deliver_later).once
      Notification::Email.notify_admins(subject, body)
    end

  end
end
