class ShowingCancelledNotifyShowingAgentWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id, before_deadline = true)
    showing = Showing.find(showing_id)
    to = showing.showing_agent_phone
    body = "Your showing appointment for #{showing.address} was cancelled outside of the 4 hour deadline. No payments will be made."
    log_msg = "Sending SMS showing cancelled notification to #{showing.showing_agent.full_name} (#{showing.showing_agent_phone}) - #{body}"
    Rails.logger.tagged("Showing: #{showing.id}", "Showing Cancelled Notification SMS") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end
end
