require "rails_helper"

describe PreferredAgentExpiredWorker do

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, user: @buyers_agent)

    to = @buyers_agent.profile.phone1
    body = "Your preferred Showing Assistant did not accept the showing in time, all Showing Assistants that match your request will now be notified."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    PreferredAgentExpiredWorker.new.perform(@showing.id)
  end

end
