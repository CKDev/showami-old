require "feature_helper"

feature "A buyers agent can perform actions on a showing" do

  context "Can create and viewing a new showing" do

    before :each do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @showing_agent = FactoryGirl.create(:user_with_valid_profile) # To receive the notification
      log_in @user
    end

    scenario "can request a new showing" do
      first(:link, "Buyer's Agent Info").click
      expect(current_path).to eq users_buyers_requests_path
      first(:link, "New Request").click
      expect(page).to have_content "Request New Showing"
      select "11 PM", from: "showing[showing_at(4i)]"
      select "55", from: "showing[showing_at(5i)]"
      fill_in "showing[mls]", with: "1234512345"
      fill_in "showing[address_attributes][line1]", with: "600 S Broadway"
      fill_in "showing[address_attributes][line2]", with: "Apt ABC"
      fill_in "showing[address_attributes][city]", with: "Denver"
      fill_in "showing[address_attributes][state]", with: "CO"
      fill_in "showing[address_attributes][zip]", with: "80209"
      fill_in "showing[notes]", with: "A whole bunch of details on the showing..."
      fill_in "showing[buyer_name]", with: "Andre"
      fill_in "showing[buyer_phone]", with: "720 999 8888"
      choose "Couple"
      click_button "Submit"
      expect(current_path).to eq users_buyers_requests_path
      expect(page).to have_content "New showing successfully created."
      expect(page).to have_content "600 S Broadway"
    end

    scenario "can click link on 'my requests' page to create a new showing" do
      visit users_buyers_requests_path
      within("main") do
        first(:link, "New Request").click
      end
      expect(current_path).to eq new_users_buyers_request_path
    end

    scenario "can view the show page of a single showing" do
      @showing = FactoryGirl.create(:showing, user: @user)
      visit users_buyers_request_path(@showing)
      within(".showing") do
        expect(page).to have_content @showing.address
      end
    end

  end

  context "Can mark a showing as a no-show" do

    before :each do
      @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
      @showing_agent = FactoryGirl.create(:user_with_valid_profile)
      @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent)
      @showing.status = "completed"
      @showing.save(validate: false)
      @buyers_agent.showings << @showing
      log_in @buyers_agent
    end

    scenario "can visit the buyers requests page and clicking the no-show button" do
      Timecop.freeze(Time.zone.now + 3.hours) do
        visit users_buyers_requests_path
        ShowingAgentBlockedNotificationWorker.expects(:perform_async).once.with(@showing.id)
        click_button "No Show"
        expect(current_path).to eq users_buyers_requests_path
        expect(page).to have_content "Showing marked as a 'no-show'."
        @showing.reload
        @showing_agent.reload
        expect(@showing.status).to eq "no_show"
        expect(@showing_agent.blocked?).to be true
      end
    end

  end

  context "Can cancel a showing" do

    before :each do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @showing = FactoryGirl.create(:showing)
      @user.showings << @showing
      log_in @user
    end

    scenario "cancels an unassigned showing by visiting the buyers requests page and clicking the cancel button" do
      visit users_buyers_requests_path
      click_button "Cancel"
      expect(current_path).to eq users_buyers_requests_path
      expect(page).to have_content "Showing cancelled"
      expect(page).to have_content @showing.address
    end

  end

end
