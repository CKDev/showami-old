require "feature_helper"

feature "A registered user can update their profile" do

  before :each do
    @user = FactoryGirl.create(:user)
    log_in @user
  end

  scenario "with basic information" do
    visit edit_users_profile_path
    find("#profile_first_name").set("Alex")
    find("#profile_last_name").set("Brinkman")
    find("#profile_phone1").set("888 555 1234 x1234")
    find("#profile_phone2").set("999 444 1234 x1234")
    find("#profile_company").set("Alex and Sons")
    find("#profile_agent_id").set("12341234") # TODO: what is the format of this number?
    find("#profile_agent_type").set(1)
    click_button "Update"
    expect(current_path).to eq(edit_users_profile_path)
    expect(page).to have_content("Profile successfully updated.")
  end

end
