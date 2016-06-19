require "rails_helper"

describe WebhookController do

  before :each do
    @showing = FactoryGirl.build(:showing,
      status: "processing_payment",
      payment_status: "paying_sellers_agent_started",
      transfer_txn: "tr_00000000000000" # Set to the same as the mock response
    )
    @showing.save(validate: false)
  end

  it "should properly handle a transfer.failed POST" do
    fixture_path = "#{Rails.root}/spec/fixtures/webhooks/transfer.failed.json"
    @transfer_failed_json = JSON.parse(File.read(fixture_path))

    post :receive, @transfer_failed_json
    @showing.reload
    expect(@showing.status).to eq "processing_payment"
    expect(@showing.payment_status).to eq "paying_sellers_agent_failure"
  end


  it "should ignore other webhooks besides the transfer.failed" do
    fixture_path = "#{Rails.root}/spec/fixtures/webhooks/transfer.paid.json"
    @transfer_paid_json = JSON.parse(File.read(fixture_path))
    post :receive, @transfer_failed_json
    @showing.reload
    expect(@showing.status).to eq "processing_payment"
    expect(@showing.payment_status).to eq "paying_sellers_agent_started"
  end

end
