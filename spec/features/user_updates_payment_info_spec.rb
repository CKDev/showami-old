require "feature_helper"

feature "A registered user can update their payment information" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
  end

  xscenario "with valid information" do
    # TODO: this needs to use a javascript driver
    visit users_cc_payment_path
    find("#cc-num").set("4242424242424242")
    find("#cc-cvc").set("123")
    find("#cc-exp-month").set("12")
    find("#cc-exp-year").set("2020")
    click_button "Save"
    expect(current_path).to eq(edit_users_profile_path)
    expect(page).to have_content("Payment information successfully added.")
  end

end
