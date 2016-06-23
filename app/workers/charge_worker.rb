class ChargeWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["unpaid", "charging_buyers_agent"]

    Log::EventLogger.info(showing.user.id, showing.id, "Sending Stripe Charge request...", "User: #{showing.user.id}", "Showing: #{showing.id}", "Charge Worker")
    showing.update(payment_status: "charging_buyers_agent")
    if Payment::Charge.new(showing.user.profile.cc_token, showing).send
      showing.update(payment_status: "charging_buyers_agent_success")
      Log::EventLogger.info(showing.user.id, showing.id, "Stripe Charge request successful.", "User: #{showing.user.id}", "Showing: #{showing.id}", "Charge Worker")
    else
      showing.update(payment_status: "charging_buyers_agent_failure")
      Log::EventLogger.error(showing.user.id, showing.id, "Stripe Charge request failed.", "User: #{showing.user.id}", "Showing: #{showing.id}", "Charge Worker")
    end
  end

end
