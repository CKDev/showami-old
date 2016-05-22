require "feature_helper"

feature "A user logs in" do

  after :each do
    log_out
  end

  scenario "is initially taken to user dashboard" do
    @user = FactoryGirl.create(:user)
    log_in @user
    expect(current_path).to eq(users_root_path)
    expect(page).to have_content "Hi, User!"
  end

end
