class ShowingAgentBlockedNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.showing_agent.profile.phone1  # TODO: Ugg, Demeter violation here (and below).
    body = "You have been blocked from further showings due to a no-show."
    log_msg = "Sending SMS showing agent blocked notification to #{showing.showing_agent.full_name} (#{showing.showing_agent.profile.phone1}) - #{body}"
    Rails.logger.tagged("Showing Agent Blocked Notification SMS") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end
end
