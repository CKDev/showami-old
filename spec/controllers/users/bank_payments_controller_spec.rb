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

      it "should set a session variable with return to the showing opportunities page after the create action is performed" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        request.env["HTTP_REFERER"] = users_showing_opportunities_url
        sign_in @user
        get :show
        expect(session[:after_successful_bank_update_path]).to eq users_showing_opportunities_url
      end

      it "should set a session variable with return to a showing opportunity page after the create action is performed" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        request.env["HTTP_REFERER"] = users_showing_opportunity_url(55)
        sign_in @user
        get :show
        expect(session[:after_successful_bank_update_path]).to eq users_showing_opportunity_url(55)
      end

      it "should set a session variable with return to a showing opportunity page after the create action is performed" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        get :show
        expect(session[:after_successful_bank_update_path]).to be nil
      end

    end

    describe "#POST create" do

      it "should call the Payment::Recipient service to create a new recipient" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        success_object = stub(send: true)
        Payment::Recipient.expects(:new).once.with("cus_tok", @user).returns(success_object)
        post :create, stripeToken: "cus_tok"
      end

      it "should properly handle a failed Stripe call" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        failure_object = stub(send: false)
        Payment::Recipient.expects(:new).once.with("cus_tok", @user).returns(failure_object)
        post :create, stripeToken: "cus_tok"
        expect(flash[:alert]).to eq "There was an error adding payment information, please try again or contact us."
      end

      it "should redirect the user back to the showing opportunities path, if that was the previous page" do
        session[:after_successful_bank_update_path] = users_showing_opportunities_url
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        success_object = stub(send: true)
        Payment::Recipient.expects(:new).once.with("cus_tok", @user).returns(success_object)
        post :create, stripeToken: "cus_tok"
        expect(response).to redirect_to users_showing_opportunities_path
      end

      it "should redirect the user back to an individual showing opportunities path, if that was the previous page" do
        @showing = FactoryGirl.create(:showing)
        session[:after_successful_bank_update_path] = users_showing_opportunity_url(@showing)
        @user = FactoryGirl.create(:user_with_valid_profile)
        sign_in @user
        success_object = stub(send: true)
        Payment::Recipient.expects(:new).once.with("cus_tok", @user).returns(success_object)
        post :create, stripeToken: "cus_tok"
        expect(response).to redirect_to users_showing_opportunity_path(@showing)
      end

    end

  end

end
