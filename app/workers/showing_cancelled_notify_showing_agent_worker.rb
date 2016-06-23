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
      Log::EventLogger.info(showing.showing_agent.id, showing.id, log_msg, "User: #{showing.showing_agent.id}", "Showing: #{showing.id}", "Showing Cancelled Showing Agent Notification SMS")
      Notification::SMS.new(to, body).send
    else
      log_msg = "No showing agent assigned, no cancellation SMS needed."
      Log::EventLogger.info(nil, showing.id, log_msg, "Showing: #{showing.id}", "Showing Cancelled Showing Agent Notification SMS")
    end
  end

  private

  def msg(showing, after_deadline)
    if after_deadline
      "Your showing appointment for #{showing.address} was cancelled after the 4 hour deadline. You will still be paid."
    else
      "Your showing appointment for #{showing.address} was cancelled before the 4 hour deadline. You will not be paid."
    end
  end
end
