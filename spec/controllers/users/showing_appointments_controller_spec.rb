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

      it "sends an SMS to the buying agent upon confirming" do
        ShowingConfirmedNotificationWorker.expects(:perform_async).once.with(@showing.id)
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

    end

  end
end
