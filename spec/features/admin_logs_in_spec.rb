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

end
