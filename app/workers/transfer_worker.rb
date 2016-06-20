class TransferWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["charging_buyers_agent_success", "paying_sellers_agent"]

    Rails.logger.tagged("Showing: #{showing.id}", "Transfer Worker") { Rails.logger.info "Sending Stripe Transfer request..." }
    showing.update(payment_status: "paying_sellers_agent")
    if Payment::Transfer.new(showing.showing_agent.profile.bank_token, showing).send
      showing.update(payment_status: "paying_sellers_agent_started")
      Rails.logger.tagged("Showing: #{showing.id}", "Transfer Worker") { Rails.logger.info "Stripe Transfer request sucessful." }
    else
      showing.update(payment_status: "paying_sellers_agent_failure")
      Rails.logger.tagged("Showing: #{showing.id}", "Transfer Worker") { Rails.logger.error "Stripe Transfer request failed." }
    end
  end

end
