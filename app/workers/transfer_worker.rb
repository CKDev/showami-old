class TransferWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["charging_buyers_agent_success", "paying_sellers_agent"]

    log_msg = "Sending a transfer request to Stripe"
    Rails.logger.tagged("Transfer Worker") { Rails.logger.info log_msg }
    showing.update(payment_status: "paying_sellers_agent")
    if Payment::Transfer.new(showing.showing_agent.profile.bank_token, showing).send
      showing.update(payment_status: "paying_sellers_agent_started")
    else
      showing.update(payment_status: "paying_sellers_agent_failure")
    end
  end

end
