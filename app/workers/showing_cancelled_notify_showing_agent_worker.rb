class ShowingCancelledNotifyShowingAgentWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id, after_deadline = true)
    showing = Showing.find(showing_id)
    if showing.showing_agent.present?
      to = showing.showing_agent_phone
      body = msg(showing, after_deadline)
      log_msg = "Sending SMS showing cancelled notification to #{showing.showing_agent.full_name} (#{showing.showing_agent_phone}) - #{body}"
      Rails.logger.tagged("Showing: #{showing.id}", "Showing Cancelled Showing Agent Notification SMS") { Rails.logger.info log_msg }
      Notification::SMS.new(to, body).send
    else
      log_msg = "No showing agent assigned, no cancellation SMS needed."
      Rails.logger.tagged("Showing: #{showing.id}", "Showing Cancelled Showing Agent Notification SMS") { Rails.logger.info log_msg }
    end
  end

  private

  def msg(showing, after_deadline)
    if after_deadline
      "Your showing appointment for #{showing.address} was cancelled after the 4 hour deadline. Payments will be required."
    else
      "Your showing appointment for #{showing.address} was cancelled before the 4 hour deadline. No payments will be required."
    end
  end
end
