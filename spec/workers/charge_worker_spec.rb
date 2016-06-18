require "rails_helper"

describe ChargeWorker do

  before :each do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing = FactoryGirl.build(:showing, user: @user, status: "processing_payment", payment_status: "unpaid")
    @showing.save(validate: false)
  end

  it "should call the Payments::Charge class with valid params" do
    success_object = stub(send: true)
    Payment::Charge.expects(:new).once.with(@user.profile.cc_token, @showing).returns(success_object)
    ChargeWorker.new.perform(@showing.id)
    @showing.reload
    expect(@showing.payment_status).to eq "charging_buyers_agent_success"
  end

  it "should set the payment_status correctly on failed Payments::Charge" do
    failure_object = stub(send: false)
    Payment::Charge.expects(:new).once.with(@user.profile.cc_token, @showing).returns(failure_object)
    ChargeWorker.new.perform(@showing.id)
    @showing.reload
    expect(@showing.payment_status).to eq "charging_buyers_agent_failure"
  end

  it "should not call the Payment::Charge object if not in processing_payment status" do
    Showing.statuses.reject { |k, _v| k == "processing_payment" }.keys.each do |s|
      @showing.status = s
      @showing.save(validate: false)
      expect do
        ChargeWorker.new.perform(@showing.id)
      end.to raise_error ArgumentError
    end
  end

  it "should not call the Payment::Charge object if not in unpaid or charging_buyers_agent payment status" do
    Showing.payment_statuses.reject { |k, _v| k == "unpaid" || k == "charging_buyers_agent" }.keys.each do |s|
      @showing.payment_status = s
      @showing.save(validate: false)
      expect do
        ChargeWorker.new.perform(@showing.id)
      end.to raise_error ArgumentError
    end
  end

end
