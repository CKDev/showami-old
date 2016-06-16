require "feature_helper"

feature "A registered user can change their account information" do

  context "Can change email and password settings" do

    after :each do
      log_out
    end

    scenario "can update with a new email address" do
      @user = FactoryGirl.create(:user)
      log_in @user
      first(:link, "Login Info").click
      expect(current_path).to eq(edit_user_registration_path)
      fill_in "user[email]", with: "alex+new@commercekitchen.com"
      fill_in "user[current_password]", with: "asdfasdf"
      click_button "Update"
      expect(current_path).to eq(edit_users_profile_path) # Redirected from root_path
      expect(page).to have_content("You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirm link to confirm your new email address.")
    end

    scenario "can update with a new password" do
      @user = FactoryGirl.create(:user)
      log_in @user
      first(:link, "Login Info").click
      expect(current_path).to eq(edit_user_registration_path)
      fill_in "user[password]", with: "ASDFASDF1234"
      fill_in "user[password_confirmation]", with: "ASDFASDF1234"
      fill_in "user[current_password]", with: "asdfasdf"
      click_button "Update"
      expect(current_path).to eq(edit_users_profile_path) # Redirected from root_path
      expect(page).to have_content("Your account has been updated successfully.")
    end

  end

  context "Can perform a password reset" do

    scenario "can reset a pby entering a valid email" do
      @user = FactoryGirl.create(:user)
      visit new_user_session_path
      click_link "Forgot your password?"
      find("#user_email").set(@user.email)
      click_button "Reset Password"
      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_content "You will receive an email with instructions on how to reset your password in a few minutes."
    end

    scenario "cannot reset forgotton password by entering an invalid email" do
      visit new_user_session_path
      click_link "Forgot your password?"
      find("#user_email").set("nonexistent@showami.com")
      click_button "Reset Password"
      expect(current_path).to eq(user_password_path)
      expect(page).to have_content "Email not found"
    end

  end

  context "Can change their user profile information" do

    before :each do
      @user = FactoryGirl.create(:user)
      log_in @user
    end

    scenario "can update with valid information" do
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
      expect(current_path).to eq(users_cc_payment_path)
      expect(page).to have_content("Profile successfully updated.")
      visit edit_users_profile_path
      click_link "Delete picture"
      expect(page).to have_content("Avatar successfully removed.")
    end

  end

end
