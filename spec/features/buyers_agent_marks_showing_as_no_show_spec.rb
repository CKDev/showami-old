require "feature_helper"

feature "A buyers agent marks a showing as a no-show" do

  before :each do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent)
    @showing.status = "completed"
    @showing.save(validate: false)
    @buyers_agent.showings << @showing
    log_in @buyers_agent
  end

  scenario "by visiting the buyers requests page and clicking the no-show button" do
    Timecop.freeze(Time.zone.now + 3.hours) do
      visit users_buyers_requests_path
      ShowingAgentBlockedNotificationWorker.expects(:perform_async).once.with(@showing.id)
      click_button "No Show"
      expect(current_path).to eq users_buyers_requests_path
      expect(page).to have_content "Showing marked as a 'no-show'."
      @showing.reload
      @showing_agent.reload
      expect(@showing.status).to eq "no_show"
      expect(@showing_agent.blocked?).to be true
    end
  end

end
