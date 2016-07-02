class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    raw_body = JSON.parse(request.body.read)
    event_type = raw_body["type"]
    Webhook.create(raw_body: raw_body, event_type: event_type)

    # The only status we care about at this time is the failure.
    if event_type == "transfer.failed"
      begin
        transaction_id = raw_body["data"]["object"]["id"]
        Showing.find_by_transfer_txn(transaction_id).update(payment_status: "paying_sellers_agent_failure")
      rescue => e
        Rails.logger.tagged("Webhook", "Stripe") { Rails.logger.error "Received a transfer.failed webhook that doesn't match a showing.  This is okay in staging, and an error in production." }
        Notification::ErrorReporter.send(e) if Rails.env.production?
      end
    end
    render nothing: true
  end

  def voice
    Rails.logger.tagged("Webhook", "Twilio", "Voice") { Rails.logger.error "Received an incoming twilio voice webhook" }
    render file: "public/twilio/voice_response.xml", content_type: "application/xml", layout: false
  end

  def sms
    Rails.logger.tagged("Webhook", "Twilio", "SMS") { Rails.logger.error "Received an incoming twilio sms webhook" }
    render file: "public/twilio/sms_response.xml", content_type: "application/xml", layout: false
  end

end
