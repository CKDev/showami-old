require "feature_helper"

feature "A user" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
  end

  scenario "can click on the Buyer's Agent Requests nav link and see their requests" do
    click_link "Buyer's Agent Requests"
    expect(current_path).to eq users_buyers_requests_path
  end

  scenario "can click on the Showing Assistant Appointments nav link and see their requests" do
    click_link "Showing Assistant Appointments"
    expect(current_path).to eq users_showing_appointments_path
  end

  scenario "can click on the Available Showing Opportunities nav link and see their requests" do
    click_link "Available Showing Opportunities"
    expect(current_path).to eq users_showing_opportunities_path
  end

end