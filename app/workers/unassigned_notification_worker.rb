class UnassignedNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    user = showing.user
    to = user.primary_phone
    body = "Warning: 30 minutes until your showing request and no one has accepted it yet #{users_buyers_request_path(showing)}."
    log_msg = "Sending Unassigned Showing Notification SMS to #{user.full_name} (#{user.primary_phone}) - #{body}"
    Log::EventLogger.info(user.id, showing_id, log_msg, "User: #{user.id}", "Showing: #{showing_id}", "Unassigned Showing Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
