class PreferredAgentExpiredWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.primary_phone
    body = "Your preferred Showing Assistant did not accept the showing in time, all Showing Assistants that match your request will now be notified."
    log_msg = "Sending Preferred Agent expriation SMS to #{showing.user.full_name} (#{to}) - #{body}"
    Log::EventLogger.info(showing.user.id, showing.id, log_msg, "User: #{showing.user.id}", "Showing: #{showing.id}", "Showing Preferred Assistant Grace Period Expired")
    Notification::SMS.new(to, body).send
  end
end
