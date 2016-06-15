require "rails_helper"

module Users
  describe ShowingAppointmentsController do

    describe "GET #index" do

      it "assigns all available assigned showings" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        @showing1 = FactoryGirl.create(:showing, showing_agent: @user)
        @showing2 = FactoryGirl.create(:showing, showing_agent: @user)
        @showing3 = FactoryGirl.create(:showing, showing_agent: @user2)
        sign_in @user
        get :index
        showings = assigns(:showings)
        expect(showings).to contain_exactly(@showing1, @showing2)
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :index
        expect(response).to redirect_to edit_users_profile_path
      end

      it "should list showings in descending date order" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing1 = FactoryGirl.create(:showing, showing_agent: @user)
        @showing2 = FactoryGirl.create(:showing, showing_agent: @user)
        @showing3 = FactoryGirl.create(:showing, showing_agent: @user)
        @showing1.showing_at = Time.zone.now - 1.month
        @showing2.showing_at = Time.zone.now + 1.month
        @showing3.showing_at = Time.zone.now
        @showing1.save(validate: false)
        @showing2.save(validate: false)
        @showing3.save(validate: false)
        sign_in @user
        get :index
        showings = assigns(:showings)
        showings << Showing.new # Accessing the array causes the array to be in the final order, I don't understand (???)
        expect(showings.first.showing_at).to eq @showing2.showing_at
        expect(showings.second.showing_at).to eq @showing3.showing_at
        expect(showings.third.showing_at).to eq @showing1.showing_at
      end

    end

    describe "POST #confirm" do

      before :each do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing)
        @showing.status = "unconfirmed"
        @showing.save(validate: false)
        sign_in @user
      end

      it "marks the showing as confirmed" do
        post :confirm, id: @showing.id
        showing = assigns(:showing)
        expect(showing.status).to eq "confirmed"
        expect(response).to redirect_to users_showing_appointments_path
      end

      it "should not allow marking a confirmed showing as confirmed again" do
        @showing.status = "confirmed"
        @showing.save(validate: false)
        ShowingConfirmedNotificationWorker.expects(:perform_async).never
        post :confirm, id: @showing.id
        expect(response).to redirect_to users_showing_appointments_path
      end

      it "sends an SMS to the buying agent upon confirming" do
        ShowingConfirmedNotificationWorker.expects(:perform_async).once.with(@showing.id)
        post :confirm, id: @showing.id
      end

      it "reports an error if the showing is not able to be confirmed" do
        @showing.status = "cancelled"
        @showing.save(validate: false)
        Notification::ErrorReporter.expects(:send).once.with(instance_of(StandardError))
        post :confirm, id: @showing.id
      end

    end

    describe "POST #cancel" do

      before :each do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing)
        sign_in @user
      end

      it "marks the showing as cancelled" do
        post :cancel, id: @showing.id
        showing = assigns(:showing)
        expect(showing.status).to eq "cancelled"
        expect(response).to redirect_to users_showing_appointments_path
      end

      it "sends an SMS to the buying agent upon cancelling" do
        ShowingCancelledNotificationWorker.expects(:perform_async).once.with(@showing.id)
        post :cancel, id: @showing.id
      end

      it "reports an error if the showing is not able to be cancelled" do
        @showing.status = "completed"
        @showing.save(validate: false)
        Notification::ErrorReporter.expects(:send).once.with(instance_of(StandardError))
        post :cancel, id: @showing.id
      end

    end

  end
end
