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

  end
end
