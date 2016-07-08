require "feature_helper"

feature "The preferred agent process" do

  before :each do
    @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
    @buyers_agent.profile.update(cc_token: "cus_8gHK0QFjGGKAMH") # Needs to be a real test env token.
    @showing_agent = FactoryGirl.create(:user_with_valid_profile)
    @showing_agent.profile.update(bank_token: "rp_18PGQxBdMtfS76Ga7u9Nqjnb") # Needs to be a real test env token.
    @preferred_agent = FactoryGirl.create(:user_with_valid_profile)
  end

  scenario "a preferred agent does not accept the showing in time" do

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
      fill_in "showing[preferred_agent]", with: @preferred_agent.email
      choose "Couple"
      click_button "Submit"
      expect(page).to have_content "New showing successfully created."
      log_out

      @showing = Showing.last
      expect(@showing.status).to eq "unassigned_with_preferred"
    end

    # After 10 minute grace period
    Timecop.freeze(Time.zone.local(2016, 6, 1, 12, 11, 0)) do
      Sidekiq::Testing.inline! do
        success_object = stub(send: true)
        Notification::SMS.expects(:new).with(@buyers_agent.primary_phone, "Your preferred Showing Assistant did not accept the showing in time, all Showing Assistants that match your request will now be notified.").returns(success_object)
        Notification::SMS.expects(:new).with(@showing_agent.primary_phone, "New Showami showing available: http://localhost:3000/users/showing_opportunities/#{@showing.id}").returns(success_object)
        Showing.update_preferred_showing # Assume cron kicked this method off.
      end

      @showing.reload
      expect(@showing.status).to eq "unassigned"
    end

  end

  scenario "the preferred agent is not a match for the showing" do

    @preferred_agent.update(blocked: true) # Something to make them not a match.

    Timecop.freeze(Time.zone.local(2016, 6, 1, 12, 0, 0)) do
      Sidekiq::Testing.inline! do
        success_object = stub(send: true)
        Notification::SMS.expects(:new).with(@buyers_agent.primary_phone, "Your preferred Showing Assistant did not match your request criteria. All matching Showing Assistants will be notified of your request.").returns(success_object)
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
        fill_in "showing[preferred_agent]", with: @preferred_agent.email
        choose "Couple"
        click_button "Submit"
        expect(page).to have_content "New showing successfully created."
        log_out
      end
    end

    @showing = Showing.last

    # After 10 minute grace period
    Timecop.freeze(Time.zone.local(2016, 6, 1, 12, 11, 0)) do
      Sidekiq::Testing.inline! do
        success_object = stub(send: true)
        Notification::SMS.expects(:new).with(@showing_agent.primary_phone, "New Showami showing available: http://localhost:3000/users/showing_opportunities/#{@showing.id}").returns(success_object)
        Notification::SMS.expects(:new).with(@buyers_agent.primary_phone, "Your preferred Showing Assistant did not accept the showing in time, all Showing Assistants that match your request will now be notified.").returns(success_object)
        Showing.update_preferred_showing # Assume cron kicked this method off.
      end
    end

  end

end
