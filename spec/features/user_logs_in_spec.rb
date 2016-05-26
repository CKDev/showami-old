require "feature_helper"

feature "A user logs in" do

  after :each do
    log_out
  end

  scenario "is initially taken to user dashboard, when they have a valid profile" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
    expect(current_path).to eq(users_root_path)
    expect(page).to have_content "Hi, Alejandro!"
  end

  scenario "is initially taken to edit profile, when they have an incomplete profile" do
    @user = FactoryGirl.create(:user)
    log_in @user
    expect(current_path).to eq(edit_users_profile_path)
    expect(page).to have_content "Hi, User!"
  end

end
