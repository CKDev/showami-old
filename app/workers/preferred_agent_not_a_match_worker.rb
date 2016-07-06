class PreferredAgentNotAMatchWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.primary_phone
    body = "Your preferred Showing Assistant did not match your request criteria. All matching Showing Assistants will be notified of your request."
    log_msg = "Sending Preferred Agent Not A Match SMS to #{showing.user.full_name} (#{to}) - #{body}"
    Log::EventLogger.info(showing.user.id, showing.id, log_msg, "User: #{showing.user.id}", "Showing: #{showing.id}", "Showing Preferred Assistant Grace Period Expired")
    Notification::SMS.new(to, body).send
  end
end
