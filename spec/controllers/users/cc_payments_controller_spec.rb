require "rails_helper"

module Users

  describe CcPaymentsController do

    describe "#GET show" do

      it "should require the user to have a valid profile" do
        @user = FactoryGirl.create(:user)
        sign_in @user
        get :show
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "#POST create" do

      it "should require the user to have a valid profile" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        customer_stub = stub(id: "cus_tok")
        Stripe::Customer.expects(:create).once.with(source: "cc_tok", email: @user.email).returns(customer_stub)
        post :create, stripeToken: "cc_tok"
        @user.reload
        expect(@user.profile.cc_token).to eq "cus_tok"
      end

      it "should properly handle a failed Stripe call" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @user.profile.update(cc_token: "")
        sign_in @user
        Stripe::Customer.expects(:create).once.with(source: "cc_tok", email: @user.email).raises(Stripe::CardError.new("A", "B", "C"))
        Notification::ErrorReporter.expects(:send).once.with(instance_of(Stripe::CardError))
        post :create, stripeToken: "cc_tok"
        expect(@user.profile.cc_token).to eq ""
        expect(response).to redirect_to users_root_path
      end

    end

  end

end
