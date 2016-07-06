require "rails_helper"

describe ShowingAcceptedByPreferredNotificationWorker do

  it "should call the sms notification class with the correct parameters" do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, user: @buyers_agent)

    to = @buyers_agent.profile.phone1
    body = "Great news! Your preferred Showing Assistant has accepted your showing."
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    ShowingAcceptedByPreferredNotificationWorker.new.perform(@showing.id)
  end

end
