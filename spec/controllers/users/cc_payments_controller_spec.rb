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

      it "should call the Payment::Customer service to create a new recipient" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        success_object = stub(send: true)
        Payment::Customer.expects(:new).once.with("cus_tok", @user).returns(success_object)
        post :create, stripeToken: "cus_tok"
      end

      it "should properly handle a failed Stripe call" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        failure_object = stub(send: false)
        Payment::Customer.expects(:new).once.with("cus_tok", @user).returns(failure_object)
        post :create, stripeToken: "cus_tok"
        expect(flash[:alert]).to eq "There was an error adding payment information, please try again or contact us."
      end

    end

  end

end
