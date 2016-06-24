class WelcomeNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(user_id)
    user = User.find(user_id)
    to = user.primary_phone
    body = "Welcome to Showami! Please add us to your contacts. Do not reply to or call this phone number. To contact us #{contact_url}."
    log_msg = "Sending welcome SMS notification to #{user.full_name} (#{user.primary_phone}) - #{body}"
    Log::EventLogger.info(user.id, nil, log_msg, "User: #{user.id}", "Welcome Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
