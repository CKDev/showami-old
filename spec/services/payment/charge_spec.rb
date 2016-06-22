require "rails_helper"

module Payment
  describe Charge do

    before :each do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @showing = FactoryGirl.create(:showing, showing_agent: @user)
      @token = "cus_8c6ev"
    end

    it "properly sends a Charge request to Stripe" do
      customer_stub = stub(id: "txn_123")
      Stripe::Charge.expects(:create).once
        .with(amount: 5_000, currency: "usd", customer: @token, description: "Buyer's agent charge for a successfully completed showing: #{@showing}")
        .returns(customer_stub)
      Payment::Charge.new(@token, @showing).send
      @showing.reload
      expect(@showing.charge_txn).to eq "txn_123"
    end

    it "properly handles a failed Charge request to Stripe" do
      Stripe::Charge.expects(:create).once.raises(Stripe::CardError.new("A", "B", "C"))
      Payment::Charge.new(@token, @showing).send
      @showing.reload
      expect(@showing.charge_txn).to be nil
    end

    it "requires a token" do
      @token = ""
      Stripe::Charge.expects(:create).never
      expect do
        Payment::Charge.new(@token, @showing).send
      end.to raise_error ArgumentError
    end

    it "requires a showing" do
      @showing = nil
      Stripe::Charge.expects(:create).never
      expect do
        Payment::Charge.new(@token, @showing).send
      end.to raise_error ArgumentError
    end
  end
end
