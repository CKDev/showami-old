require "rails_helper"

module Admin
  describe UsersController do

    describe "GET #index" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        sign_in @admin
      end

      it "assigns all users in the system" do
        get :index
        expect(assigns(:users).count).to eq 3
      end

    end

    describe "GET #show" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        sign_in @admin
      end

      it "assigns the requested user" do
        get :show, id: @user2.id
        expect(assigns(:user)).to eq @user2
      end

    end

    describe "POST #unblock" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile, blocked: true)
        sign_in @admin
      end

      it "assigns the requested user" do
        expect(@user1.blocked?).to be true
        post :unblock, id: @user1.id
        @user1.reload
        expect(@user1.blocked?).to be false
      end

    end

  end
end
