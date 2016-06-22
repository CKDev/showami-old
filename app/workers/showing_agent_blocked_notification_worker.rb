class ShowingAgentBlockedNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.showing_agent_phone
    body = "You have been blocked from further showings due to a no-show."
    log_msg = "Sending SMS showing agent blocked notification to #{showing.showing_agent} (#{to}) - #{body}"
    Log::EventLogger.info(nil, showing.id, log_msg, "Showing: #{showing.id}", "Showing Agent Blocked Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
