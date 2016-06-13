require "rails_helper"

module Users

  describe BankPaymentsController do

    describe "#GET show" do

      it "should require the user to have a valid profile" do
        @user = FactoryGirl.create(:user)
        sign_in @user
        get :show
        expect(response).to redirect_to edit_users_profile_path
      end

    end

    describe "#POST create" do

      it "should properly set the bank_token value on the user's profile" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        recipient_stub = stub(id: "btok_8cACLVzy8yNsq0")
        Stripe::Recipient.expects(:create)
          .once.with(name: @user.full_name, type: "individual", email: @user.email, bank_account: "cus_tok")
          .returns(recipient_stub)
        post :create, stripeToken: "cus_tok"
        @user.reload
        expect(@user.profile.bank_token).to eq "btok_8cACLVzy8yNsq0"
      end

      it "should properly handle a failed Stripe call" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @user.profile.update(bank_token: "")
        sign_in @user
        Stripe::Recipient.expects(:create)
          .once.with(name: @user.full_name, type: "individual", email: @user.email, bank_account: "cus_tok")
          .raises(StandardError, "A Stripe Error Occurred")
        Notification::ErrorReporter.expects(:send).once.with(instance_of(StandardError))
        post :create, stripeToken: "cus_tok"
        expect(@user.profile.bank_token).to eq ""
        expect(response).to redirect_to users_root_path
      end

    end

  end

end
