require "feature_helper"

feature "A registered user can update their profile" do

  before :each do
    @user = FactoryGirl.create(:user)
    log_in @user
  end

  scenario "with valid information" do
    visit edit_users_profile_path
    find("#profile_first_name").set("Alex")
    find("#profile_last_name").set("Brinkman")
    find("#profile_phone1").set("888 555 1234")
    find("#profile_phone2").set("999 444 1234")
    find("#profile_company").set("Alex and Sons")
    find("#profile_agent_id").set("12341234") # TODO: what is the format of this number?
    choose "I'm a buyer's agent and I want assistance with showings"
    attach_file "profile[avatar]", Rails.root + "spec/fixtures/avatar.png"
    click_button "Update"
    expect(current_path).to eq(edit_users_profile_path)
    expect(page).to have_content("Profile successfully updated.")
    click_link "Delete picture"
    expect(page).to have_content("Avatar successfully removed.")
  end

end
