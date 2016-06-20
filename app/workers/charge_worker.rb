class ChargeWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform(showing_id)
    showing = Showing.find(showing_id)

    raise ArgumentError unless showing.status == "processing_payment"
    raise ArgumentError unless showing.payment_status.in? ["unpaid", "charging_buyers_agent"]

    Rails.logger.tagged("Showing: #{showing.id}", "Charge Worker") { Rails.logger.info "Sending Stripe Charge request..." }
    showing.update(payment_status: "charging_buyers_agent")
    if Payment::Charge.new(showing.user.profile.cc_token, showing).send
      showing.update(payment_status: "charging_buyers_agent_success")
      Rails.logger.tagged("Showing: #{showing.id}", "Charge Worker") { Rails.logger.info "Stripe Charge request sucessful." }
    else
      showing.update(payment_status: "charging_buyers_agent_failure")
      Rails.logger.tagged("Showing: #{showing.id}", "Charge Worker") { Rails.logger.error "Stripe Charge request failed." }
    end
  end

end
