require "feature_helper"

feature "A guest user" do

  scenario "can view the homepage" do
    visit root_path
    expect(page).to have_content("Sign Up")
  end

  scenario "can view the about page" do
    visit root_path
    click_link "About"
    expect(page).to have_content("About Showami")
  end

  scenario "can view the privacy policy page" do
    visit root_path
    click_link "Privacy Policy"
    expect(page).to have_content("Privacy Policy")
  end

  scenario "can view the terms and conditions page" do
    visit root_path
    click_link "Terms"
    expect(page).to have_content("Terms and Conditions")
  end

  scenario "can view the contact page" do
    visit root_path
    click_link "Contact"
    expect(page).to have_content("Contact Us")
  end

  scenario "is not able to get to the sidekiq dashboard" do
    visit sidekiq_web_path
    expect(current_path).to eq(new_user_session_path)
  end

end
