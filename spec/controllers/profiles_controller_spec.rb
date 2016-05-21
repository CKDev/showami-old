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
          agent_type: 0
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
        expect(@user.profile.phone1).to eq "303 333 4444"
        expect(@user.profile.phone2).to eq "720 444 5555"
        expect(@user.profile.company).to eq "Cannon Beach Real Estate"
        expect(@user.profile.agent_id).to eq "1234-1234"
        expect(@user.profile.agent_type).to eq 0
      end

      it "re-renders the form if invalid" do
        valid_attributes[:first_name] = ""
        post :update, profile: valid_attributes
        expect(response).to render_template :edit
      end

    end

  end
end
