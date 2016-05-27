require "feature_helper"

feature "A user" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
  end

  scenario "can click on the Buyer's Agent nav link and see their requests" do
    first(:link, "Buyer's Agent Info").click
    expect(current_path).to eq users_buyers_requests_path
  end

  scenario "can click on the Showing Assistant nav link and see their requests" do
    first(:link, "Showing Assistant Info").click
    expect(current_path).to eq users_showing_appointments_path
  end

  scenario "can click on the Available Showing Opportunities nav link and see their requests" do
    first(:link, "Showing Assistant Info").click
    first(:link, "Showing Opportunities").click
    expect(current_path).to eq users_showing_opportunities_path
  end

end
