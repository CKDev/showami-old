require "feature_helper"

feature "A showing agent can perform actions on a showing" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    log_in @user
  end

  scenario "can accept an available showing by visiting the show page (from SMS link) and clicking the accept button" do
    visit users_showing_opportunity_path(id: @showing.id)
    click_button "Accept"
    expect(current_path).to eq users_showing_appointments_path
    expect(page).to have_content "Showing accepted"
    within(".showing") do
      expect(page).to have_content @showing.address.single_line
    end
  end

  scenario "can confirm an accepted (unconfirmed) showing by visiting their showings page and clicking the confirm button" do
    @showing.update(showing_agent: @user, status: "unconfirmed")
    visit users_showing_appointments_path
    click_button "Confirm"
    expect(current_path).to eq users_showing_appointments_path
    expect(page).to have_content "Showing confirmed"
    within(".showing") do
      expect(page).to have_content @showing.address.single_line
      expect(page).to have_content "Confirmed"
    end
  end

  scenario "can cancel an accepted (unconfirmed) showing by visiting their showings page and clicking the cancel button" do
    @showing.update(showing_agent: @user, status: "unconfirmed")
    visit users_showing_appointments_path
    click_button "Cancel"
    expect(current_path).to eq users_showing_appointments_path
    expect(page).to have_content "Showing cancelled"
    within(".showing") do
      expect(page).to have_content @showing.address.single_line
      expect(page).to have_content "Cancelled"
    end
  end

end
