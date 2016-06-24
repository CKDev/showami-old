require "rails_helper"

module Admin
  describe UsersController do

    describe "GET #index" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
      end

      it "assigns all users in the system, except for the logged in admin" do
        sign_in @admin
        get :index
        expect(assigns(:users).count).to eq 2
      end

      it "is not available to non-admins" do
        sign_in @user1
        get :index
        expect(response).to redirect_to root_path
      end

    end

    describe "GET #show" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
      end

      it "assigns the requested user" do
        sign_in @admin
        get :show, id: @user1.id
        expect(assigns(:user)).to eq @user1
      end

      it "assigns the requested events in ascending date order" do
        @event1 = FactoryGirl.create(:event_log, user: @user1, created_at: Time.zone.now - 2.days)
        @event2 = FactoryGirl.create(:event_log, user: @user1, created_at: Time.zone.now - 5.days)
        @event3 = FactoryGirl.create(:event_log, user: @user1, created_at: Time.zone.now - 1.days)
        sign_in @admin
        get :show, id: @user1.id
        user = assigns(:user)
        expect(user.event_logs.first).to eq @event3
        expect(user.event_logs.second).to eq @event1
        expect(user.event_logs.third).to eq @event2
      end

      it "is not available to non-admins" do
        sign_in @user1
        get :show, id: @user1.id
        expect(response).to redirect_to root_path
      end

    end

    describe "POST #unblock" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile, blocked: true)
      end

      it "assigns the requested user" do
        sign_in @admin
        expect(@user1.blocked?).to be true
        post :unblock, id: @user1.id
        @user1.reload
        expect(@user1.blocked?).to be false
      end

      it "is not available to non-admins" do
        sign_in @user1
        post :unblock, id: @user1.id
        expect(response).to redirect_to root_path
      end

    end

    describe "POST #block" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
      end

      it "assigns the requested user" do
        sign_in @admin
        expect(@user1.blocked?).to be false
        post :block, id: @user1.id
        @user1.reload
        expect(@user1.blocked?).to be true
      end

      it "is not available to non-admins" do
        sign_in @user1
        post :block, id: @user1.id
        expect(response).to redirect_to root_path
      end

    end

    describe "POST #confirm" do

      before :each do
        @admin = FactoryGirl.create(:user_with_valid_profile, admin: true)
        @user1 = FactoryGirl.create(:user_with_valid_profile)
      end

      it "assigns the requested user" do
        sign_in @admin
        @user1.update(confirmed_at: nil)
        post :confirm, id: @user1.id
        @user1.reload
        expect(@user1.confirmed_at).to be_within(2.seconds).of(Time.zone.now)
      end

      it "is not available to non-admins" do
        sign_in @user1
        post :confirm, id: @user1.id
        expect(response).to redirect_to root_path
      end

    end

  end
end
