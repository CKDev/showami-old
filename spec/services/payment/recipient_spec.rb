require "rails_helper"

module Payment
  describe Recipient do

    before :each do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(bank_token: nil)
      @token = "cus_8c6ev"
    end

    it "properly sends a Recipient request to Stripe" do
      recipient_stub = stub(id: "rp_123")
      Stripe::Recipient.expects(:create).once
        .with(name: @user.full_name, type: "individual", email: @user.email, bank_account: @token)
        .returns(recipient_stub)
      Payment::Recipient.new(@token, @user).send
      @user.reload
      expect(@user.profile.bank_token).to eq "rp_123"
    end

    it "properly handles a failed Recipient request to Stripe" do
      Stripe::Recipient.expects(:create).once.raises(Stripe::InvalidRequestError.new("A", "B"))
      Payment::Recipient.new(@token, @user).send
      @user.reload
      expect(@user.profile.bank_token).to be nil
    end

    it "requires a token" do
      @token = ""
      Stripe::Recipient.expects(:create).never
      expect do
        Payment::Recipient.new(@token, @user).send
      end.to raise_error ArgumentError
    end

    it "requires a user" do
      @user = nil
      Stripe::Recipient.expects(:create).never
      expect do
        Payment::Recipient.new(@token, @user).send
      end.to raise_error ArgumentError
    end
  end
end
