require "rails_helper"

describe ShowingNotificationWorker do

  it "should call the sms noticiation class with the correct parameters" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    to = @user.profile.phone1
    body = "There is a new showing available at: #{@showing.address.single_line}"
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingNotificationWorker.new
    worker.perform(@user.id, @showing.id)
  end

end
