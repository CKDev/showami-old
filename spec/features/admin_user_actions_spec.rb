require "feature_helper"

feature "An admin user" do

  before :each do
    @admin = FactoryGirl.create(:admin)
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    log_in @admin
  end

  scenario "can view all users in the system" do
    visit admin_root_path
    expect(page).to have_content "Users"
    user_count = find_all("tr").size
    expect(user_count).to eq 3 # 2 users and a header row
    expect(page).to have_content "Name"
    expect(page).to have_content "Email"
    expect(page).to have_content "Agent Type"
    expect(page).to have_content "Details"
  end

  scenario "can view the details of a single user" do
    visit admin_root_path
    within find("tr", text: @showing_agent.email) do
      click_link "Show Details"
    end
    expect(current_path).to eq admin_user_path(@showing_agent)
    expect(page).to have_content @showing_agent.full_name
    expect(page).to have_content @showing_agent.email
    expect(page).to have_content "(555) 123-1234"
    expect(page).to have_content "(555) 987-1234"
    expect(page).to have_content @showing_agent.profile.agent_id
    expect(page).to have_content @showing_agent.profile.agent_type_str
    expect(page).to have_content @showing_agent.profile.company

    click_link "<< Back to all users"
  end

  scenario "can unblock a user" do
    @showing_agent.update(blocked: true)
    visit admin_user_path(@showing_agent)
    click_button "Unblock"
    @showing_agent.reload
    expect(@showing_agent.blocked).to be false
  end

  scenario "can block a user" do
    visit admin_user_path(@showing_agent)
    click_button "Block"
    @showing_agent.reload
    expect(@showing_agent.blocked).to be true
  end

  scenario "can confirm a user" do
    @showing_agent.update(confirmed_at: nil)
    visit admin_user_path(@showing_agent)
    click_button "Confirm"
    @showing_agent.reload
    expect(@showing_agent.confirmed_at.present?).to be true
  end

end
