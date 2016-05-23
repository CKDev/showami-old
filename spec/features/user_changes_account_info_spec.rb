require "feature_helper"

feature "A registered user can change their account information" do

  after :each do
    log_out
  end

  scenario "with a new email address" do
    @user = FactoryGirl.create(:user)
    log_in @user
    click_link "Edit your email or password"
    expect(current_path).to eq(edit_user_registration_path)
    fill_in "user[email]", with: "alex+new@commercekitchen.com"
    fill_in "user[current_password]", with: "asdfasdf"
    click_button "Update"
    expect(current_path).to eq(root_path)
    expect(page).to have_content("You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirm link to confirm your new email address.")
  end

  scenario "with a new password" do
    @user = FactoryGirl.create(:user)
    log_in @user
    click_link "Edit your email or password"
    expect(current_path).to eq(edit_user_registration_path)
    fill_in "user[password]", with: "ASDFASDF1234"
    fill_in "user[password_confirmation]", with: "ASDFASDF1234"
    fill_in "user[current_password]", with: "asdfasdf"
    click_button "Update"
    expect(current_path).to eq(root_path)
    expect(page).to have_content("Your account has been updated successfully.")
  end

end
