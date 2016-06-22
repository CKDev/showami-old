require "rails_helper"

module Payment
  describe Transfer do

    before :each do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @showing = FactoryGirl.create(:showing, showing_agent: @user)
      @token = "rp_abcd123"
    end

    it "properly sends a Transfer request to Stripe" do
      transfer_stub = stub(id: "txn_123")
      Stripe::Transfer.expects(:create).once
        .with(amount: 4_000, currency: "usd", recipient: @token,
          statement_descriptor: "Seller's agent payment transfer for a successfully completed showing: #{@showing}")
        .returns(transfer_stub)
      Payment::Transfer.new(@token, @showing).send
      @showing.reload
      expect(@showing.transfer_txn).to eq "txn_123"
    end

    it "properly handles a failed Transfer request to Stripe" do
      Stripe::Transfer.expects(:create).once
        .raises(Stripe::InvalidRequestError.new("A", "B"))
      Payment::Transfer.new(@token, @showing).send
      @showing.reload
      expect(@showing.transfer_txn).to be nil
    end

    it "requires a token" do
      @token = ""
      Stripe::Transfer.expects(:create).never
      expect do
        Payment::Transfer.new(@token, @showing).send
      end.to raise_error ArgumentError
    end

    it "requires a showing" do
      @showing = nil
      Stripe::Transfer.expects(:create).never
      expect do
        Payment::Transfer.new(@token, @showing).send
      end.to raise_error ArgumentError
    end
  end
end
