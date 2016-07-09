require "rails_helper"

module Users
  describe BuyersRequestsController do

    describe "POST #create" do

      let(:valid_attributes) do
        {
          showing_at: Time.zone.now + 3.hours,
          mls: "abc123",
          notes: "notes about the showing",
          address_attributes: {
            line1: "600 S Broadway",
            line2: "Unit 200",
            city: "Denver",
            state: "CO",
            zip: "80209"
          },
          buyer_name: "Andre",
          buyer_phone: "720 999 8888",
          buyer_type: "individual",
          preferred_agent: ""
        }
      end

      let(:bad_address) do
        {
          showing_at: Time.zone.now + 3.hours,
          mls: "abc123",
          notes: "notes about the showing",
          address_attributes: {
            line1: "abc",
            line2: "",
            city: "abc",
            state: "abc",
            zip: "12"
          },
          buyer_name: "Andre",
          buyer_phone: "720 999 8888",
          buyer_type: "individual"
        }
      end

      before :each do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
      end

      it "correctly assigns the passed in info" do
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.user).to eq @user
        expect(showing.showing_at).to be_within(5.seconds).of(Time.zone.now + 3.hours)
        expect(showing.mls).to eq "abc123"
        expect(showing.notes).to eq "notes about the showing"
        expect(showing.address.line1).to eq "600 S Broadway"
        expect(showing.address.line2).to eq "Unit 200"
        expect(showing.address.city).to eq "Denver"
        expect(showing.address.state).to eq "CO"
        expect(showing.address.zip).to eq "80209"
        expect(showing.buyer_name).to eq "Andre"
        expect(showing.buyer_phone).to eq "7209998888"
        expect(showing.buyer_type).to eq "individual"
      end

      it "re-renders the form if invalid" do
        valid_attributes[:showing_at] = ""
        post :create, showing: valid_attributes
        expect(response).to render_template :new
      end

      it "assigns the latitude and longitude of the showing address" do
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.address.latitude).to_not be nil
        expect(showing.address.longitude).to_not be nil
      end

      it "notifies all seller agent users whose bounding box contains the address of the showing" do
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user1.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        @user2.profile.update(geo_box: "(-100, 39.500), (-101.000, 40.000)") # Not in bounding box
        @user3 = FactoryGirl.create(:user_with_valid_profile)
        @user3.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        @user3.profile.update(agent_type: "buyers_agent")
        User.any_instance.expects(:notify_new_showing).once
        post :create, showing: valid_attributes
      end

      it "does not notify the user creating the showing (even if their bounding box contains the showing address)" do
        @user.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        User.any_instance.expects(:notify_new_showing).never
        post :create, showing: valid_attributes
      end

      it "does not notify blocked users " do
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user1.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        @user1.update(blocked: true)
        User.any_instance.expects(:notify_new_showing).never
        post :create, showing: valid_attributes
      end

      it "warns the user if the address of the showing was unable to be geocoded" do
        post :create, showing: bad_address
        expect(response).to render_template :new
      end

      it "prevents a new showing from being created without a valid credit card on file" do
        @user.profile.update(cc_token: "")
        expect do
          post :create, showing: valid_attributes
        end.not_to change { Showing.count }
        expect(response).to redirect_to users_cc_payment_path
      end

      it "prevents a new showing from being created when the buyer's agent is blocked" do
        @user.update(blocked: true)
        expect do
          post :create, showing: valid_attributes
        end.not_to change { Showing.count }
        expect(response).to redirect_to users_buyers_requests_path
      end

      it "allows for a preferred agent" do
        @preferred_agent = FactoryGirl.create(:user_with_valid_profile)
        valid_attributes[:preferred_agent_email] = @preferred_agent.email
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.preferred_agent).to eq @preferred_agent
      end

      it "sets the initial status to unassigned_with_preferred, if a preferred agent is given" do
        @preferred_agent = FactoryGirl.create(:user_with_valid_profile)
        valid_attributes[:preferred_agent_email] = @preferred_agent.email
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.status).to eq "unassigned_with_preferred"
      end

      it "if an unknown user is entered for preferred agent, they are sent a welcome email" do
        valid_attributes[:preferred_agent_email] = "notauser@example.com"
        success_object = stub(deliver_later: true)
        UserMailer.expects(:invite).once.with("notauser@example.com").returns(success_object)
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.preferred_agent).to be nil
      end

      it "if an unknown user is entered for preferred agent, other users aren't notified until 10 minutes" do
        @showing_agent = FactoryGirl.create(:user_with_valid_profile)
        User.any_instance.expects(:notify_new_showing).never
        valid_attributes[:preferred_agent_email] = "notauser@example.com"
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.status).to eq "unassigned_with_preferred"
      end

      it "notifies other showing agents immediately if a known user, who is not a match for the showing, is entered for preferred agent" do
        @preferred_agent = FactoryGirl.create(:user_with_valid_profile, blocked: true)
        @showing_agent = FactoryGirl.create(:user_with_valid_profile)
        User.any_instance.expects(:notify_new_showing).once
        PreferredAgentNotAMatchWorker.expects(:perform_async).once
        valid_attributes[:preferred_agent_email] = @preferred_agent.email
        post :create, showing: valid_attributes
        expect(Showing.last.status).to eq "unassigned"
      end

      it "notifies only preferred agent initially" do
        @preferred_agent = FactoryGirl.create(:user_with_valid_profile)
        @other_user = FactoryGirl.create(:user_with_valid_profile)
        @other_user2 = FactoryGirl.create(:user_with_valid_profile)

        User.any_instance.expects(:notify_new_preferred_showing).once.with(instance_of(Showing))

        valid_attributes[:preferred_agent_email] = @preferred_agent.email
        post :create, showing: valid_attributes
      end

      it "notifies all matching agents immediately if no preferred agent is given" do
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        @user3 = FactoryGirl.create(:user_with_valid_profile)

        User.any_instance.expects(:notify_new_showing).times(3).with(instance_of(Showing))

        valid_attributes[:preferred_agent_email] = ""
        post :create, showing: valid_attributes
      end

      it "sends an SMS to the buying agent if their preferred agent does not meet the parameters of the showing" do
        @preferred_agent = FactoryGirl.create(:user_with_valid_profile, blocked: true)
        @other_user = FactoryGirl.create(:user_with_valid_profile)
        @other_user2 = FactoryGirl.create(:user_with_valid_profile)

        User.any_instance.expects(:notify_new_showing).twice
        PreferredAgentNotAMatchWorker.expects(:perform_async).once

        valid_attributes[:preferred_agent_email] = @preferred_agent.email
        post :create, showing: valid_attributes
      end

    end

    describe "GET #index" do

      it "should assign all showings for the given user" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, user: @user)
        sign_in @user
        get :index
        expect(assigns(:showings).size).to be 1
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :index
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "GET #new" do

      it "assigns a new showing and address" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        get :new
        showing = assigns(:showing)
        expect(showing).to be_an_instance_of(Showing)
        expect(showing.address).to be_an_instance_of(Address)
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :new
        expect(response).to redirect_to edit_users_profile_path
      end

      it "prevents the new showing view to be accessed without a valid credit card on file" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @user.profile.update(cc_token: nil)
        sign_in @user
        get :new
        expect(response).to redirect_to users_cc_payment_path
      end

      it "prevents a new showing from being created when the buyer's agent is blocked" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @user.update(blocked: true)
        sign_in @user
        get :new
        expect(response).to redirect_to users_buyers_requests_path
      end

    end

    describe "GET #show" do

      it "assigns the requested showing and address" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, user: @user)
        sign_in @user
        get :show, id: @showing.id
        showing = assigns(:showing)
        expect(showing).to be_an_instance_of(Showing)
      end

      it "doesn't assign the showing if it's not the current user's showing" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @other_user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, user: @other_user)
        sign_in @user
        get :show, id: @showing.id
        expect(assigns(:showing)).to be nil
        expect(response).to redirect_to users_buyers_requests_path
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        @showing = FactoryGirl.create(:showing)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :show, id: @showing.id
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "POST #cancel" do

      before :each do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, user: @user, showing_at: Time.zone.now + 4.hours + 1.minute)
        sign_in @user
      end

      it "marks the showing as cancelled" do
        post :cancel, id: @showing.id
        showing = assigns(:showing)
        expect(showing.status).to eq "cancelled"
      end

      it "should not allow marking an cancelled showing as cancelled again" do
        @showing.status = "cancelled"
        @showing.save(validate: false)
        post :cancel, id: @showing.id
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to users_buyers_requests_path
      end

      it "doesn't allow someone to cancel a showing that isn't theirs" do
        @other_user = FactoryGirl.create(:user_with_valid_profile)
        @other_user_showing = FactoryGirl.create(:showing, user: @other_user)
        sign_in @user
        post :cancel, id: @other_user_showing.id
        @other_user_showing.reload
        expect(assigns(:showing)).to be nil
        expect(@other_user_showing.status).to eq "unassigned"
        expect(response).to redirect_to users_buyers_requests_path
      end

      it "checks that the showing is more than 4 hours away, sends an SMS to the showing agent that the showing is cancelled, and no payment will be made" do
        @showing.showing_at = Time.zone.now + 4.hours + 1.minute
        @showing.status = "confirmed"
        @showing.save(validate: false)
        ShowingCancelledNotifyShowingAgentWorker.expects(:perform_async).with(@showing.id, false).once
        post :cancel, id: @showing.id
        @showing.reload
        expect(@showing.status).to eq "cancelled"
      end

      it "checks that the showing is less than 4 hours away, sends an SMS to the showing agent that the showing is cancelled, and payment will be made" do
        @showing.showing_at = Time.zone.now + 3.hours + 59.minutes
        @showing.status = "confirmed"
        @showing.save(validate: false)
        ShowingCancelledNotifyShowingAgentWorker.expects(:perform_async).with(@showing.id, true).once
        post :cancel, id: @showing.id
        @showing.reload
        expect(@showing.status).to eq "cancelled_with_payment"
      end

      it "sets the showing to cancelled, and doesn't send SMS (handled by worker, not here) if no showing agent accepted the showing" do
        @showing.showing_at = Time.zone.now + 3.hours + 59.minutes
        @showing.status = "unassigned"
        @showing.save(validate: false)
        ShowingCancelledNotifyShowingAgentWorker.expects(:perform_async).with(@showing.id, false).once
        post :cancel, id: @showing.id
        @showing.reload
        expect(@showing.status).to eq "cancelled"
      end

    end

    describe "POST #no_show" do

      before :each do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing_agent = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, showing_agent: @showing_agent, user: @user)
        @showing.status = "completed"
        @showing.save(validate: false)
        sign_in @user
      end

      it "marks the showing as a 'no show'" do
        post :no_show, id: @showing.id
        @showing.reload
        expect(@showing.status).to eq "no_show"
      end

      it "can only mark a showing as a 'no show' for 24 hours after the showing time" do
        @showing.showing_at = Time.zone.now
        @showing.save(validate: false)

        Timecop.freeze(Time.zone.now + 24.hours + 1.minute) do
          post :no_show, id: @showing.id
          showing = assigns(:showing)
          showing.reload
          expect(showing.errors.messages.count).to eq 1
          expect(showing.status).to eq "completed"
        end
      end

      it "should not allow marking an no-show showing as no-show again" do
        @showing.status = "no_show"
        @showing.save(validate: false)
        ShowingAgentBlockedNotificationWorker.expects(:perform_async).never
        post :no_show, id: @showing.id
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to users_buyers_requests_path
      end

      it "sets the blocked flag on the showing agent" do
        post :no_show, id: @showing.id
        @showing_agent.reload
        expect(@showing_agent.blocked).to be true
      end

      it "sends an SMS to the showing agent that they are blocked from accepting showings" do
        ShowingAgentBlockedNotificationWorker.expects(:perform_async).once.with(@showing.id)
        post :no_show, id: @showing.id
      end

      it "doesn't allow someone to mark a showing as a no-show that isn't theirs" do
        @other_user = FactoryGirl.create(:user_with_valid_profile)
        @other_user_showing = FactoryGirl.create(:showing, user: @other_user)
        @other_user_showing.status = "completed"
        @other_user_showing.save(validate: false)
        sign_in @user
        post :no_show, id: @other_user_showing.id
        @other_user_showing.reload
        expect(assigns(:showing)).to be nil
        expect(@other_user_showing.status).to eq "completed"
        expect(response).to redirect_to users_buyers_requests_path
      end

    end

  end
end
