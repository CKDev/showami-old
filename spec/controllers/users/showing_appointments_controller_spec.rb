require "rails_helper"

module Users
  describe ShowingAppointmentsController do

    it "should redirect to the user profile view if the user's profile isn't valid" do
      @user = FactoryGirl.create(:user)
      expect(@user.profile.valid?).to be false
      sign_in @user
      get :index
      expect(response).to redirect_to edit_users_profile_path
    end

  end
end
