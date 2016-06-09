require "rails_helper"

module Users
  describe ProfilesController do

    describe "POST #update" do

      let(:valid_attributes) do
        {
          first_name: "Alex",
          last_name: "Brinkman",
          phone1: "303 333 4444",
          phone2: "720 444 5555",
          company: "Cannon Beach Real Estate",
          agent_id: "1234-1234",
          agent_type: "buyers_agent",
          geo_box: "(105.2705 , 40.0150), (105.000, 40.000)",
          geo_box_zoom: 10
        }
      end

      before :each do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "correctly assigns the passed in info" do
        post :update, profile: valid_attributes
        @user.profile.reload
        expect(@user.profile.first_name).to eq "Alex"
        expect(@user.profile.last_name).to eq "Brinkman"
        expect(@user.profile.phone1).to eq "3033334444"
        expect(@user.profile.phone2).to eq "7204445555"
        expect(@user.profile.company).to eq "Cannon Beach Real Estate"
        expect(@user.profile.agent_id).to eq "1234-1234"
        expect(@user.profile.agent_type).to eq "buyers_agent"
        expect(@user.profile.geo_box).to eq "(105.2705 , 40.0150), (105.000, 40.000)"
        expect(@user.profile.geo_box_zoom).to eq 10
      end

      it "re-renders the form if invalid" do
        valid_attributes[:first_name] = ""
        post :update, profile: valid_attributes
        expect(response).to render_template :edit
      end

      it "takes the user to the cc payment view, if they are a buyer's agent and they don't have payment on record" do
        post :update, profile: valid_attributes
        expect(response).to redirect_to users_cc_payment_path
      end

      it "takes the user to the cc payment view, if they are both a buyer's and seller's agent and they don't have payment on record" do
        valid_attributes[:agent_type] = "both"
        post :update, profile: valid_attributes
        expect(response).to redirect_to users_cc_payment_path
      end

      it "takes the user back to the profile view, if they are a buyer's agent and they have payment on record" do
        valid_attributes[:agent_type] = "buyers_agent"
        post :update, profile: valid_attributes
        @user.profile.reload
        @user.profile.update(cc_token: "something valid")
        post :update, profile: valid_attributes
        expect(response).to redirect_to edit_users_profile_path
      end

      it "takes the user back to the profile view, if they are both buyer's and seller's agent and they have payment on record" do
        valid_attributes[:agent_type] = "both"
        post :update, profile: valid_attributes
        @user.profile.reload
        @user.profile.update(cc_token: "something valid")
        @user.profile.update(bank_token: "something valid")
        post :update, profile: valid_attributes
        expect(response).to redirect_to edit_users_profile_path
      end

      it "takes the user to the bank payment view, if they are a seller's agent and they don't have payment on record" do
        valid_attributes[:agent_type] = "sellers_agent"
        post :update, profile: valid_attributes
        expect(response).to redirect_to users_bank_payment_path
      end

      it "takes the user back to the profile view, if they are a seller's agent and they have payment on record" do
        valid_attributes[:agent_type] = "sellers_agent"
        post :update, profile: valid_attributes
        @user.profile.reload
        @user.profile.update(bank_token: "something valid")
        post :update, profile: valid_attributes
        expect(response).to redirect_to edit_users_profile_path
      end

      it "takes the user to the bank payment view, if they are both buyer's and seller's agent and they have cc payment but not bank payment on record" do
        valid_attributes[:agent_type] = "both"
        post :update, profile: valid_attributes
        @user.profile.reload
        @user.profile.update(cc_token: "something valid")
        post :update, profile: valid_attributes
        expect(response).to redirect_to users_bank_payment_path
      end

    end

    describe "POST #delete_avatar" do

      before :each do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
      end

      it "correctly removes the avatar from the profile" do
        post :delete_avatar
        @user.profile.reload
        expect(@user.profile.avatar.present?).to be false
      end

    end

  end
end
