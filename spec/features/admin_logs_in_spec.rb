require "feature_helper"

feature "An admin logs in" do

  after :each do
    log_out
  end

  scenario "is initially taken to admin dashboard" do
    @admin = FactoryGirl.create(:admin)
    log_in @admin
    expect(current_path).to eq(admin_root_path)
  end

  scenario "is able to get to the sidekiq dashboard" do
    @admin = FactoryGirl.create(:admin)
    log_in @admin
    visit sidekiq_web_path
    expect(current_path).to eq(sidekiq_web_path)
    visit admin_root_path
  end

end
