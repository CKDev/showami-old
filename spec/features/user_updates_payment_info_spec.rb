# Note: this is commented out because getting the Stripe js to work
# with a js enabled capybara driver proved to be tricky, and I never
# found a working solution.  It was manually tested very well.

# require "feature_helper"

# feature "A registered user can update their payment information" do

#   before :each do
#     @user = FactoryGirl.create(:user_with_valid_profile)
#     log_in @user
#   end

#   xscenario "with valid information", js: true do
#     visit users_cc_payment_path
#     find("#cc-num").set("4242424242424242")
#     find("#cc-cvc").set("123")
#     find("#cc-exp-month").set("12")
#     find("#cc-exp-year").set("2020")
#     click_button "Save"
#     expect(current_path).to eq(edit_users_profile_path)
#     expect(page).to have_content("Payment information successfully added.")
#   end

# end
