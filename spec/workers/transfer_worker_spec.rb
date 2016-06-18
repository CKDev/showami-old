require "rails_helper"

describe TransferWorker do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.build(:showing, user: @user, status: "processing_payment", payment_status: "charging_buyers_agent_success")
    @showing.save(validate: false)
  end

  it "should call the Payments::Transfer class with valid params" do
    success_object = stub(send: true)
    Payment::Transfer.expects(:new).once.with(@user.profile.bank_token, @showing).returns(success_object)
    TransferWorker.new.perform(@showing.id)
    @showing.reload
    expect(@showing.payment_status).to eq "paying_sellers_agent_started"
  end

  it "should set the payment_status correctly on failed Payments::Transfer" do
    failure_object = stub(send: false)
    Payment::Transfer.expects(:new).once.with(@user.profile.bank_token, @showing).returns(failure_object)
    TransferWorker.new.perform(@showing.id)
    @showing.reload
    expect(@showing.payment_status).to eq "paying_sellers_agent_failure"
  end

  it "should not call the Payment::Transfer object if not in processing_payment status" do
    Showing.statuses.reject { |k, _v| k == "processing_payment" }.keys.each do |s|
      @showing.status = s
      @showing.save(validate: false)
      expect do
        TransferWorker.new.perform(@showing.id)
      end.to raise_error ArgumentError
    end
  end

  it "should not call the Payment::Transfer object if not in paying_sellers_agent payment status" do
    Showing.payment_statuses.reject { |k, _v| k == "charging_buyers_agent_success" || k == "paying_sellers_agent" }.keys.each do |s|
      @showing.payment_status = s
      @showing.save(validate: false)
      expect do
        TransferWorker.new.perform(@showing.id)
      end.to raise_error ArgumentError
    end
  end

end
