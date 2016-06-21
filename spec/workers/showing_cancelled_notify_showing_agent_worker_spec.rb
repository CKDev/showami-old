require "rails_helper"

describe ShowingCancelledNotifyShowingAgentWorker do

  it "should call the sms notification class with the correct parameters" do
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent)

    to = @showing_agent.profile.phone1
    body = "Your showing appointment for #{@showing.address} was cancelled outside of the 4 hour deadline. No payments will be made."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingCancelledNotifyShowingAgentWorker.new
    worker.perform(@showing.id)
  end

end
