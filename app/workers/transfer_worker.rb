class TransferWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["charging_buyers_agent_success", "paying_sellers_agent"]

    Log::EventLogger.info(nil, showing.id, "Sending Stripe Transfer request...", "Showing: #{showing.id}", "Transfer Worker")
    showing.update(payment_status: "paying_sellers_agent")
    if Payment::Transfer.new(showing.showing_agent.profile.bank_token, showing).send
      showing.update(payment_status: "paying_sellers_agent_started")
      Log::EventLogger.info(nil, showing.id, "Stripe Transfer request sucessful.", "Showing: #{showing.id}", "Transfer Worker")
    else
      showing.update(payment_status: "paying_sellers_agent_failure")
      Log::EventLogger.error(nil, showing.id, "Stripe Transfer request failed.", "Showing: #{showing.id}", "Transfer Worker")
    end
  end

end
