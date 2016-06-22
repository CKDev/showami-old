require "rails_helper"

describe ShowingCancelledNotifyShowingAgentWorker do

  it "should call the sms notification class with the parameters for before deadline cancelation" do
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent)

    to = @showing_agent.profile.phone1
    body = "Your showing appointment for #{@showing.address} was cancelled before the 4 hour deadline. You will not be paid."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingCancelledNotifyShowingAgentWorker.new
    worker.perform(@showing.id, false)
  end

  it "should call the sms notification class with the parameters for an after deadline cancelation" do
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent)

    to = @showing_agent.profile.phone1
    body = "Your showing appointment for #{@showing.address} was cancelled after the 4 hour deadline. You will still be paid."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    worker = ShowingCancelledNotifyShowingAgentWorker.new
    worker.perform(@showing.id, true)
  end

  it "should not call the sms notification class if no showing agent is available (cancelled before accepted)" do
    @showing = FactoryGirl.create(:showing)
    Notification::SMS.expects(:new).never
    ShowingCancelledNotifyShowingAgentWorker.new.perform(@showing.id, true)
  end

end
