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
          },
          buyer_name: "Andre",
          buyer_phone: "720 999 8888",
          buyer_type: "individual"
        }
      end

      let(:bad_address) do
        {
          showing_at: Time.zone.now + 3.hours,
          mls: "abc123",
          notes: "notes about the showing",
          address_attributes: {
            line1: "abc",
            line2: "",
            city: "abc",
            state: "abc",
            zip: "12"
          },
          buyer_name: "Andre",
          buyer_phone: "720 999 8888",
          buyer_type: "individual"
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
        expect(showing.buyer_name).to eq "Andre"
        expect(showing.buyer_phone).to eq "720 999 8888"
        expect(showing.buyer_type).to eq "individual"
      end

      it "re-renders the form if invalid" do
        valid_attributes[:showing_at] = ""
        post :create, showing: valid_attributes
        expect(response).to render_template :new
      end

      it "assigns the latitude and longitude of the showing address" do
        post :create, showing: valid_attributes
        showing = Showing.last
        expect(showing.address.latitude).to_not be nil
        expect(showing.address.longitude).to_not be nil
      end

      it "notifies all seller agent users whose bounding box contains the address of the showing" do
        @user1 = FactoryGirl.create(:user_with_valid_profile)
        @user1.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        @user2.profile.update(geo_box: "(-100, 39.500), (-101.000, 40.000)") # Not in bounding box
        @user3 = FactoryGirl.create(:user_with_valid_profile)
        @user3.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        @user3.profile.update(agent_type: "buyers_agent")
        User.any_instance.expects(:notify_new_showing).once
        post :create, showing: valid_attributes
      end

      it "does not notify the user creating the showing (even if their bounding box contains the showing address)" do
        @user.profile.update(geo_box: "(-104.98384092330923, 39.70858488314164), (-104.99103678226453, 39.70222470324933)")
        User.any_instance.expects(:notify_new_showing).never
        post :create, showing: valid_attributes
      end

      it "warns the user if the address of the showing was unable to be geocoded" do
        post :create, showing: bad_address
        expect(response).to render_template :new
      end

    end

    describe "GET #index" do

      it "should assign all showings for the given user" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing)
        @user.showings << @showing
        sign_in @user
        get :index
        expect(assigns(:showings).size).to be 1
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :index
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "GET #new" do

      it "assigns a new showing and address" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        get :new
        showing = assigns(:showing)
        expect(showing).to be_an_instance_of(Showing)
        expect(showing.address).to be_an_instance_of(Address)
      end

      it "should redirect to the user profile view if the user's profile isn't valid" do
        @user = FactoryGirl.create(:user)
        expect(@user.profile.valid?).to be false
        sign_in @user
        get :new
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

  end
end
