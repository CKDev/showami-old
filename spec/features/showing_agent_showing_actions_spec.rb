require "feature_helper"

feature "A showing agent can perform actions on a showing" do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.create(:showing)
    log_in @user
  end

  context "Can accept a showing" do

    scenario "can accept an available showing by visiting the show page (from SMS link) and clicking the accept button" do
      visit users_showing_opportunity_path(id: @showing.id)
      click_button "Accept"

      expect(current_path).to eq users_showing_appointments_path
      expect(page).to have_content "Showing accepted"
      within(".showing") do
        expect(page).to have_content @showing.address
        expect(page).to have_button "Confirm"
        expect(page).to have_button "Cancel"
      end

      visit users_showing_opportunity_path(@showing)
      within(".showing") do
        expect(page).to have_content @showing.address
        expect(page).to have_content "Unconfirmed"
      end
    end

    scenario "cannot accept an available showing if they do not have a bank token" do
      @user.profile.update(bank_token: "")
      visit users_showing_opportunity_path(id: @showing.id)
      expect(page).to have_content "Add your bank information to be able to accept showings"

      visit users_showing_opportunities_path
      expect(page).to have_content "Add your bank information to be able to accept showings"
    end

    scenario "is not shown the bank CTA if the showing isn't available" do
      @user.profile.update(bank_token: "")
      @other_user = FactoryGirl.create(:user_with_valid_profile)
      @showing.update(status: "unconfirmed", showing_agent: @other_user)
      visit users_showing_opportunity_path(id: @showing.id)
      within(".showing") do
        expect(page).to have_content "Assigned"
      end
    end

  end

  context "Can confirm a showing" do

    scenario "can confirm an accepted (unconfirmed) showing by visiting their showings page and clicking the confirm button" do
      @showing.update(showing_agent: @user, status: "unconfirmed")
      visit users_showing_appointments_path
      click_button "Confirm"
      expect(current_path).to eq users_showing_appointments_path
      expect(page).to have_content "Showing confirmed"
      within(".showing") do
        expect(page).to have_content @showing.address
        expect(page).to have_content "Confirmed"
      end
    end

    scenario "will see the showing as reserved on the showing page if it has been claimed by someone else" do
      @other_user = FactoryGirl.create(:user_with_valid_profile)
      @showing.update(showing_agent: @other_user, status: "unconfirmed")

      visit users_showing_opportunity_path(@showing)
      within(".showing") do
        expect(page).to have_content @showing.address
        expect(page).to have_content "Reserved"
      end
    end

  end

  context "Can cancel a showing" do

    scenario "will see the showing as cancelled on the showing page if it has since been cancelled" do
      @showing.update(status: "cancelled")
      visit users_showing_opportunity_path(@showing)
      within(".showing") do
        expect(page).to have_content @showing.address
        expect(page).to have_content "Cancelled"
      end
    end

    scenario "can cancel an accepted (unconfirmed) showing by visiting their showings page and clicking the cancel button" do
      @showing.update(showing_agent: @user, status: "unconfirmed")
      visit users_showing_appointments_path
      click_button "Cancel"
      expect(current_path).to eq users_showing_appointments_path
      expect(page).to have_content "Showing cancelled"
      within(".showing") do
        expect(page).to have_content @showing.address
        expect(page).to have_content "Cancelled"
      end
    end

  end

  context "Can view a showing" do

    scenario "can click on the Showing Assistant nav link and see their requests" do
      first(:link, "Showing Assistant Info").click
      expect(current_path).to eq users_showing_appointments_path
    end

    scenario "can click on the Available Showing Opportunities nav link and see their requests" do
      first(:link, "Showing Assistant Info").click
      first(:link, "Showing Opportunities").click
      expect(current_path).to eq users_showing_opportunities_path
    end

  end

end
