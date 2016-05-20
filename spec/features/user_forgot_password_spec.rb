require "feature_helper"

feature "A user resets forgotton password" do

  scenario "is initially taken to user dashboard" do
    @user = FactoryGirl.create(:user)
    visit new_user_session_path
    click_link "Forgot your password?"
    find("#user_email").set(@user.email)
    click_button "Reset Password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content "You will receive an email with instructions on how to reset your password in a few minutes."
  end

end
