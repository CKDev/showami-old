require "feature_helper"

feature "A user signs up" do

  scenario "signs up from default sign up path, with valid credentials" do
    visit new_user_registration_path
    find("#user_email").set("user@showami.com")
    find("#user_password").set("asdfasdf")
    find("#user_password_confirmation").set("asdfasdf")
    click_button "Sign up"
    expect(current_path).to eq(root_path)
    expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
  end

  scenario "signs up from root path, with valid credentials" do
    visit root_path
    find("#user_email").set("user@showami.com")
    find("#user_password").set("asdfasdf")
    find("#user_password_confirmation").set("asdfasdf")
    click_button "Sign up"
    expect(current_path).to eq(root_path)
    expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
  end

end
