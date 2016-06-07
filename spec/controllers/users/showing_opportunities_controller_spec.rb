require "rails_helper"

module Users
  describe ShowingOpportunitiesController do

    describe "GET #index" do

      it "assigns all available showings (in bounding box, in future, unassigned)" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing1 = FactoryGirl.create(:showing, showing_at: Time.zone.now + 3.hours)
        sign_in @user
        get :index
        showings = assigns(:showings)
        expect(showings).to contain_exactly(@showing1)
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :index
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "GET #show" do

      it "assigns the requested showing and address" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing)
        sign_in @user
        get :show, id: @showing.id
        showing = assigns(:showing)
        expect(showing).to be_an_instance_of(Showing)
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

    describe "POST #update" do

      it "updates the showing to have the correct status" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing)
        sign_in @user
        post :update, id: @showing.id, commit: "Accept"
        showing = assigns(:showing)
        expect(showing).to be_an_instance_of(Showing)
      end

    end

  end
end
