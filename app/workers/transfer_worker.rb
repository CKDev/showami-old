class TransferWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["charging_buyers_agent_success", "paying_sellers_agent"]

    Log::EventLogger.info(showing.showing_agent.id, showing.id, "Sending Stripe Transfer request...", "User: #{showing.showing_agent.id}", "Showing: #{showing.id}", "Transfer Worker")
    showing.update(payment_status: "paying_sellers_agent")
    if Payment::Transfer.new(showing.showing_agent.profile.bank_token, showing).send
      showing.update(payment_status: "paying_sellers_agent_started")
      Log::EventLogger.info(showing.showing_agent.id, showing.id, "Stripe Transfer request sucessful.", "User: #{showing.showing_agent.id}", "Showing: #{showing.id}", "Transfer Worker")
    else
      showing.update(payment_status: "paying_sellers_agent_failure")
      Log::EventLogger.error(showing.showing_agent.id, showing.id, "Stripe Transfer request failed.", "User: #{showing.showing_agent.id}", "Showing: #{showing.id}", "Transfer Worker")
    end
  end

end
