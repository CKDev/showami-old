require "feature_helper"

feature "A user logs in" do

  after :each do
    log_out
  end

  scenario "is initially taken to dashboard" do
    @user = FactoryGirl.create(:user)
    log_in @user
    expect(current_path).to eq(root_path)
  end

end
