require "feature_helper"

feature "A user logs in" do

  after :each do
    log_out
  end

  scenario "is initially taken to the buyers request path, when they have a valid profile" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
    expect(current_path).to eq(users_buyers_requests_path)
  end

  scenario "is initially taken to edit profile, when they have an incomplete profile" do
    @user = FactoryGirl.create(:user)
    log_in @user
    expect(current_path).to eq(edit_users_profile_path)
  end

  scenario "is not able to get to the admin dashboard" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
    visit admin_root_path
    expect(current_path).to eq(root_path)
  end

  scenario "is not able to get to the sidekiq dashboard" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    log_in @user
    expect do
      visit sidekiq_web_path
    end.to raise_error ActionController::RoutingError
  end

end
