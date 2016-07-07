require "rails_helper"

describe ShowingAgentBlockedNotificationWorker do

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, user: @buyers_agent, showing_agent: @showing_agent)

    to = @showing_agent.profile.phone1
    body = "It was reported that you did not show up to a showing. You are now blocked from accepting showings. Contact us http://localhost:3000/contact"
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingAgentBlockedNotificationWorker.new
    worker.perform(@showing.id)
  end

end
