require "rails_helper"

describe ApplicationController do

  describe "#after_signin_path_for" do

    it "should redirect admins to the admin dashboard" do
      @admin = FactoryGirl.create(:admin)
      expect(@controller.after_sign_in_path_for(@admin)).to eq admin_root_path
    end

    it "should redirect users without a valid profile to the profile view" do
      @user = FactoryGirl.create(:user)
      expect(@controller.after_sign_in_path_for(@user)).to eq edit_users_profile_path
    end

    it "should redirect 'both' agents users with a valid profile to the profile view" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(agent_type: "both")
      expect(@controller.after_sign_in_path_for(@user)).to eq users_buyers_requests_path
    end

    it "should redirect 'buyers' agents users with a valid profile to the profile view" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(agent_type: "buyers_agent")
      expect(@controller.after_sign_in_path_for(@user)).to eq users_buyers_requests_path
    end

    it "should redirect 'sellers' agents users with a valid profile to the profile view" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(agent_type: "sellers_agent")
      expect(@controller.after_sign_in_path_for(@user)).to eq users_showing_appointments_path
    end

  end

  describe "#after_sign_out_path_for" do

    it "should redirect users to the sign_in page, not the homepage" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      expect(@controller.after_sign_out_path_for(@user)).to eq new_user_session_path
    end

  end

end
