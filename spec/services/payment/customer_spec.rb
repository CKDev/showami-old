require "rails_helper"

module Payment
  describe Customer do

    before :each do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(cc_token: nil)
      @token = "cus_8c6ev"
    end

    it "properly sends a Customer request to Stripe" do
      customer_stub = stub(id: "cc_123")
      Stripe::Customer.expects(:create).once
        .with(source: @token, email: @user.email)
        .returns(customer_stub)
      Payment::Customer.new(@token, @user).send
      @user.reload
      expect(@user.profile.cc_token).to eq "cc_123"
    end

    it "properly handles a failed Customer request to Stripe" do
      Stripe::Customer.expects(:create).once.raises(Stripe::InvalidRequestError.new("A", "B"))
      Payment::Customer.new(@token, @user).send
      @user.reload
      expect(@user.profile.cc_token).to be nil
    end

    it "requires a token" do
      @token = ""
      Stripe::Customer.expects(:create).never
      expect do
        Payment::Customer.new(@token, @user).send
      end.to raise_error ArgumentError
    end

    it "requires a user" do
      @user = nil
      Stripe::Customer.expects(:create).never
      expect do
        Payment::Customer.new(@token, @user).send
      end.to raise_error ArgumentError
    end
  end
end
