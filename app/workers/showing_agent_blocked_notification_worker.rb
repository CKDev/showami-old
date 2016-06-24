class ShowingAgentBlockedNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.showing_agent_phone
    body = "It was reported that you did not show up to a showing. You are now blocked from accepting showings. Contact us #{link}"
    log_msg = "Sending SMS showing agent blocked notification to #{showing.showing_agent} (#{to}) - #{body}"
    Log::EventLogger.info(showing.showing_agent.id, showing.id, log_msg, "User: #{showing.showing_agent.id}", "Showing: #{showing.id}", "Showing Agent Blocked Notification SMS")
    Notification::SMS.new(to, body).send
  end

  private

  def link
    return "https://showami.com/contact" if Rails.env.production? # Ensure no-www to keep under 140 characters.
    contact_url
  end
end
