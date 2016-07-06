class ShowingAcceptedByPreferredNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.primary_phone
    body = "Great news! Your preferred Showing Assistant has accepted your showing."
    log_msg = "Sending SMS showing accepted by preferred assistant notification to #{showing.user.full_name} (#{showing.user.profile.phone1}) - #{body}"
    Log::EventLogger.info(showing.user.id, showing.id, log_msg, "User: #{showing.user.id}", "Showing: #{showing.id}", "Preferred Showing Accepted Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
