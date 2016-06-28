require "rails_helper"

describe UnassignedNotificationWorker do

  include Rails.application.routes.url_helpers

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, user: @buyers_agent, showing_agent: @showing_agent)
    to = @buyers_agent.profile.phone1
    body = "Warning: 30 minutes until your showing request and no one has accepted it yet #{users_buyers_request_url(@showing)}."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    UnassignedNotificationWorker.new.perform(@showing.id)
  end

end
