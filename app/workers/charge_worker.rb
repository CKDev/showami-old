class ChargeWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["unpaid", "charging_buyers_agent"]

    log_msg = "Sending a charge request to Stripe"
    Rails.logger.tagged("Charge Worker") { Rails.logger.info log_msg }
    showing.update(payment_status: "charging_buyers_agent")
    if Payment::Charge.new(showing.user.profile.cc_token, showing).send
      showing.update(payment_status: "charging_buyers_agent_success")
    else
      showing.update(payment_status: "charging_buyers_agent_failure")
    end
  end

end
