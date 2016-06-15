require "rails_helper"

describe ShowingAcceptedNotificationWorker do

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @buyers_agent.showings << @showing

    to = @buyers_agent.profile.phone1
    body = "Your showing request was accepted: #{@showing.address}.  For more details visit: http://localhost:3000/users/buyers_requests"
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingAcceptedNotificationWorker.new
    worker.perform(@showing.id)
  end

end
