require "feature_helper"

feature "The entire showing process" do

  before :each do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @buyers_agent.profile.update(cc_token: "cus_8gHK0QFjGGKAMH") # Needs to be a real test env token.
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent.profile.update(bank_token: "rp_18PGQxBdMtfS76Ga7u9Nqjnb") # Needs to be a real test env token.
    @preferred_agent = FactoryGirl.create(:user_with_valid_profile)
  end

  scenario "from start to finish" do
    Timecop.freeze(Time.zone.local(2016, 6, 1, 12, 0, 0)) do
      log_in @buyers_agent
      visit new_users_buyers_request_path
      select "02 PM", from: "showing[showing_at(4i)]"
      select "00", from: "showing[showing_at(5i)]"
      fill_in "showing[mls]", with: "12345-12345"
      fill_in "showing[address_attributes][line1]", with: "600 S Broadway"
      fill_in "showing[address_attributes][city]", with: "Denver"
      fill_in "showing[address_attributes][state]", with: "CO"
      fill_in "showing[address_attributes][zip]", with: "80209"
      fill_in "showing[notes]", with: "A whole bunch of details on the showing..."
      fill_in "showing[buyer_name]", with: "Andre"
      fill_in "showing[buyer_phone]", with: "720 999 8888"
      choose "Couple"
      click_button "Submit"
      expect(page).to have_content "New showing successfully created."
      log_out

      @showing = Showing.last

      log_in @showing_agent
      visit users_showing_opportunity_path(id: @showing.id)
      click_button "Accept"
      expect(page).to have_content "Showing accepted"
      click_button "Confirm"
      expect(page).to have_content "Showing confirmed"
      log_out
    end

    # After showing time
    Timecop.freeze(Time.zone.local(2016, 6, 1, 14, 30, 0)) do
      Showing.update_completed # Assume cron kicked this method off.
      @showing.reload
      expect(@showing.status).to eq "completed"
    end

    # After 24 hour no-show period
    Timecop.freeze(Time.zone.local(2016, 6, 2, 14, 30, 0)) do
      expect(@showing.payment_status).to eq "unpaid"
      Showing.start_payment_charges # Assume cron kicked this method off.
      ChargeWorker.new.perform(@showing.id) # Kick this off manually since sidekiq doesn't run in test.
      @showing.reload
      expect(@showing.status).to eq "processing_payment"
      expect(@showing.payment_status).to eq "charging_buyers_agent_success"

      Showing.start_payment_transfers # Assume cron kicked this method off.
      TransferWorker.new.perform(@showing.id)
      @showing.reload
      expect(@showing.status).to eq "processing_payment"
      expect(@showing.payment_status).to eq "paying_sellers_agent_started"
    end

    # After 5 more business days of not receiving the failed webhook
    Timecop.freeze(Time.zone.local(2016, 6, 9, 14, 30, 0)) do
      Showing.update_paid # Assume cron kicked this method off.
      @showing.reload
      expect(@showing.status).to eq "paid"
      expect(@showing.payment_status).to eq "paying_sellers_agent_success"
    end

  end

end
