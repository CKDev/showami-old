require "rails_helper"

describe WebhookController do

  before :each do
    @showing = FactoryGirl.build(
      :showing,
      status: "processing_payment",
      payment_status: "paying_sellers_agent_started",
      transfer_txn: "tr_00000000000000" # Set to the same as the mock response
    )
    @showing.save(validate: false)
  end

  it "should properly handle a transfer.failed POST" do
    fixture_path = "#{Rails.root}/spec/fixtures/webhooks/transfer.failed.json"
    @transfer_failed_json = JSON.parse(File.read(fixture_path))
    expect do
      post :receive, @transfer_failed_json.to_json
    end.to change { Webhook.count }.by(1)

    @showing.reload
    expect(@showing.status).to eq "processing_payment"
    expect(@showing.payment_status).to eq "paying_sellers_agent_failure"

    webhook = Webhook.last
    expect(webhook.raw_body).to_not be nil
    expect(webhook.event_type).to eq "transfer.failed"
  end

  it "should ignore (except for logging) other webhooks besides the transfer.failed" do
    fixture_path = "#{Rails.root}/spec/fixtures/webhooks/transfer.paid.json"
    @transfer_paid_json = JSON.parse(File.read(fixture_path))
    expect do
      post :receive, @transfer_paid_json.to_json
    end.to change { Webhook.count }.by(1)
    @showing.reload
    expect(@showing.status).to eq "processing_payment"
    expect(@showing.payment_status).to eq "paying_sellers_agent_started"

    webhook = Webhook.last
    expect(webhook.raw_body).to_not be nil
    expect(webhook.event_type).to eq "transfer.paid"
  end

  it "should properly handle a transfer.failed POST, where the showing transfer_txn isn't found" do
    @showing.update(transfer_txn: "ASDF")
    fixture_path = "#{Rails.root}/spec/fixtures/webhooks/transfer.failed.json"
    @transfer_failed_json = JSON.parse(File.read(fixture_path))
    expect do
      post :receive, @transfer_failed_json.to_json
    end.to_not raise_error

  end

end
