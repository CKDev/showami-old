require "rails_helper"

describe ConfirmationReminderWorker do

  include Rails.application.routes.url_helpers

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, user: @buyers_agent, showing_agent: @showing_agent)
    to = @showing_agent.profile.phone1
    body = "Please remember to confirm your showing. #{users_showing_opportunity_url(@showing)}"
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    ConfirmationReminderWorker.new.perform(@showing.id)
  end

end
