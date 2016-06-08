require "feature_helper"

feature "A buyers agent cancels an unassigned showing" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    @user.showings << @showing
    log_in @user
  end

  scenario "by visiting the buyers requests page and clicking the cancel button" do
    visit users_buyers_requests_path
    click_button "Cancel"
    expect(current_path).to eq users_buyers_requests_path
    expect(page).to have_content "Showing cancelled"
    expect(page).to have_content @showing.address.single_line
  end

end
