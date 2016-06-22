class ShowingAcceptedNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.profile.phone1
    body = "Your showing request was accepted: #{showing.address}.  For more details visit: #{users_buyers_requests_url}"
    log_msg = "Sending SMS showing accepted notification to #{showing.user.full_name} (#{showing.user.profile.phone1}) - #{body}"
    Log::EventLogger.info(nil, showing.id, log_msg, "Showing: #{showing.id}", "Showing Accepted Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
