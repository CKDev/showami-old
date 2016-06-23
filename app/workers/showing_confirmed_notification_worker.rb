class ShowingConfirmedNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.primary_phone
    body = "Your showing request was confirmed: #{showing.address}.  For more details visit: #{users_buyers_requests_url}"
    log_msg = "Sending SMS showing confirmed notification to #{showing.user.full_name} (#{showing.user.profile.phone1}) - #{body}"
    Log::EventLogger.info(showing.user.id, showing.id, log_msg, "User: #{showing.user.id}", "Showing: #{showing.id}", "Showing Confirmed Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
