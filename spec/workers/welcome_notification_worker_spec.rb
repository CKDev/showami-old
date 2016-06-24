require "rails_helper"

describe WelcomeNotificationWorker do

  it "should call the sms notification class with the correct parameters" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    to = @user.profile.phone1
    body = "Welcome to Showami! Please add us to your contacts. Do not reply to or call this phone number. To contact us http://localhost:3000/contact."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    WelcomeNotificationWorker.new.perform(@user.id)
  end

end
