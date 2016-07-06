require "rails_helper"

describe PreferredShowingNotificationWorker do

  it "should call the sms notification class with the correct parameters" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    to = @user.profile.phone1
    body = "You are the preferred showing assistant for this showing and you have a 10 min head start: http://localhost:3000/users/showing_opportunities/#{@showing.id}"
    success_object = stub(send: true)
    Notification::SMS.expects(:new).once.with(to, body).returns(success_object)
    PreferredShowingNotificationWorker.new.perform(@user.id, @showing.id)
  end

end
