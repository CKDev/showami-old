class ShowingNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(user_id, showing_id)
    user = User.find(user_id)
    showing = Showing.find(showing_id)
    to = user.profile.phone1
    showing_url = users_showing_opportunity_url(showing_id)

    body = "New Showami showing available: #{showing_url}"
    log_msg = "Sending SMS showing notification to #{user.full_name} (#{user.profile.phone1}) -  New Showing: #{showing.address}"
    Log::EventLogger.info(nil, showing.id, log_msg, "Showing: #{showing.id}", "Showing Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
