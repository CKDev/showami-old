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
          }
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
      end

      it "re-renders the form if invalid" do
        valid_attributes[:showing_at] = ""
        post :create, showing: valid_attributes
        expect(response).to render_template :new
      end

    end

    describe "GET #index" do

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :index
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "GET #new" do

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :new
        expect(response).to redirect_to edit_users_profile_path
      end

    end

  end
end
