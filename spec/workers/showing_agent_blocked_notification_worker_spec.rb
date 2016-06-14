require "rails_helper"

describe ShowingAgentBlockedNotificationWorker do

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent)
    @buyers_agent.showings << @showing

    to = @showing_agent.profile.phone1
    body = "You have been blocked from further showings due to a no-show."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingAgentBlockedNotificationWorker.new
    worker.perform(@showing.id)
  end

end
