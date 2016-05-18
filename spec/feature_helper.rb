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
