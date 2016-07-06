class PreferredShowingNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(user_id, showing_id)
    user = User.find(user_id)
    showing = Showing.find(showing_id)
    to = user.primary_phone
    showing_url = users_showing_opportunity_url(showing_id)
    body = "You are the preferred showing assistant for this showing and you have a 10 min head start: #{showing_url}"
    log_msg = "Sending Preferred SMS showing notification to #{user.full_name} (#{user.primary_phone}) -  New Showing: #{showing.address}"
    Log::EventLogger.info(user.id, showing.id, log_msg, "User: #{user.id}", "Showing: #{showing.id}", "Preferred Showing Notification SMS")
    Notification::SMS.new(to, body).send
  end
end
