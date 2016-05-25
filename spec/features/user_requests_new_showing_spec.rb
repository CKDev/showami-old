require "feature_helper"

feature "A registered user with valid payment" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
  end

  scenario "can request a new showing" do
    click_link "Buyer's Agent Requests"
    expect(current_path).to eq users_buyers_requests_path
    click_link "New Request"
    expect(page).to have_content "Request New Showing"
    select "Dec", from: "showing[showing_at(2i)]"
    select "31", from: "showing[showing_at(3i)]"
    select "11 PM", from: "showing[showing_at(4i)]"
    select "55", from: "showing[showing_at(5i)]"
    fill_in "showing[mls]", with: "1234512345"
    fill_in "showing[address_attributes][line1]", with: "600 S Broadway"
    fill_in "showing[address_attributes][line2]", with: "Apt ABC"
    fill_in "showing[address_attributes][city]", with: "Denver"
    fill_in "showing[address_attributes][state]", with: "CO"
    fill_in "showing[address_attributes][zip]", with: "80209"
    fill_in "showing[notes]", with: "A whole bunch of details on the showing..."
    click_button "Submit"
    expect(current_path).to eq users_buyers_requests_path
    expect(page).to have_content "New showing successfully created."
    expect(page).to have_content "600 S Broadway"
  end

end
