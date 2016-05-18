require "rails_helper"
require "capybara/rails"
require "capybara/rspec"

Capybara.javascript_driver = :webkit
# Capybara.javascript_driver = :selenium

# Capybara::Webkit.configure do |config|
# config.debug = true # Uncomment for error information.
# end

Capybara.configure do |config|
  config.always_include_port = true
end


def log_in_with(email, password)
  visit new_session_path
  find("#user_email").set(email)
  find("#user_password").set(password)
  click_button "Log in"
end

def log_in(user)
  visit root_path
  click_link "Log In"
  find("#user_email", visible: false).set(user.email)
  find("#user_password", visible: false).set(user.password)
  click_button "Log in"
end

def log_out
  click_link "Log Out"
end