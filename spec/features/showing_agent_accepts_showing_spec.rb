require "feature_helper"

feature "A showing agent accepts a new showing" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    log_in @user
  end

  scenario "by visiting the individual showing page (from SMS link) an clicking the accept button" do
    visit users_showing_opportunity_path(id: @showing.id) # Most likely from the SMS notification
    click_button "Accept"
    expect(current_path).to eq users_showing_opportunities_path
    expect(page).to have_content "Showing accepted"
  end

end
