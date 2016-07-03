require "feature_helper"

feature "A guest user" do

  scenario "can view the homepage" do
    visit root_path
    expect(page).to have_content("Sign Up")
  end

  scenario "can view the about page" do
    visit root_path
    click_link "About"
    expect(page).to have_content("About")
    expect(page).to have_content("Leverage your time • Grow your business • Meet your client’s needs • Get your life back")
  end

  scenario "can view the privacy policy page" do
    visit root_path
    click_link "Privacy Policy"
    expect(page).to have_content("Privacy Policy")
  end

  scenario "can view the terms and conditions page" do
    visit root_path
    click_link "Application End User License Agreement"
    expect(page).to have_content("Application End User License Agreement")
  end

  scenario "can view the contact page" do
    visit root_path
    click_link "Contact"
    expect(page).to have_content("Contact")
    expect(page).to have_content("Have a question? Want to learn how Showami")
    expect(page).to have_content("Contact us at admin@showami.com")
  end

  scenario "is not able to get to the sidekiq dashboard" do
    visit sidekiq_web_path
    expect(current_path).to eq(new_user_session_path)
  end

end
