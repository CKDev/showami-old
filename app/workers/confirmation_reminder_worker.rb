class ConfirmationReminderWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    user = showing.showing_agent
    to = user.primary_phone
    body = "Please remember to confirm your showing. #{users_showing_opportunity_path(showing_id)}"
    log_msg = "Sending confirmation reminder SMS notification to #{user.full_name} (#{user.primary_phone}) - #{body}"
    Log::EventLogger.info(user.id, showing_id, log_msg, "User: #{user.id}", "Showing: #{showing_id}", "Confirmation Reminder SMS")
    Notification::SMS.new(to, body).send
  end
end
