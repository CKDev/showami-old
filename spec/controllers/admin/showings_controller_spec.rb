require "rails_helper"

module Admin
  describe ShowingsController do

    describe "GET #show" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, user: @user1, showing_agent: @user2)
        sign_in @admin
      end

      it "assigns the requested user" do
        get :show, id: @showing.id
        expect(assigns(:showing)).to eq @showing
      end

    end

  end
end
