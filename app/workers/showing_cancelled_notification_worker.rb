class ShowingCancelledNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.profile.phone1
    body = "Your showing request was cancelled: #{showing.address.single_line}.  For more details visit: #{users_buyers_requests_url}"
    log_msg = "Sending SMS showing cancelled notification to #{showing.user.full_name} (#{showing.user.profile.phone1}) - #{body}"
    Rails.logger.tagged("Showing Cancelled Notification SMS") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end
end
