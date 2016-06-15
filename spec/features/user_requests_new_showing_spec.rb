require "feature_helper"

feature "A buyers agent" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile) # To receive the notification
    log_in @user
  end

  scenario "can request a new showing" do
    first(:link, "Buyer's Agent Info").click
    expect(current_path).to eq users_buyers_requests_path
    first(:link, "New Request").click
    expect(page).to have_content "Request New Showing"

    # A valid time is somewhat dependent on when the test is run, just changing the time
    # will mostly work, though using something like TimeCop would be better here.
    # select "Dec", from: "showing[showing_at(2i)]"
    # select "31", from: "showing[showing_at(3i)]"
    select "11 PM", from: "showing[showing_at(4i)]"
    select "55", from: "showing[showing_at(5i)]"
    fill_in "showing[mls]", with: "1234512345"
    fill_in "showing[address_attributes][line1]", with: "600 S Broadway"
    fill_in "showing[address_attributes][line2]", with: "Apt ABC"
    fill_in "showing[address_attributes][city]", with: "Denver"
    fill_in "showing[address_attributes][state]", with: "CO"
    fill_in "showing[address_attributes][zip]", with: "80209"
    fill_in "showing[notes]", with: "A whole bunch of details on the showing..."
    fill_in "showing[buyer_name]", with: "Andre"
    fill_in "showing[buyer_phone]", with: "720 999 8888"
    choose "Couple"
    click_button "Submit"
    expect(current_path).to eq users_buyers_requests_path
    expect(page).to have_content "New showing successfully created."
    expect(page).to have_content "600 S Broadway"
  end

  scenario "can click link on 'my requests' page to create a new showing" do
    visit users_buyers_requests_path
    within("main") do
      first(:link, "New Request").click
    end
    expect(current_path).to eq new_users_buyers_request_path
  end

end
