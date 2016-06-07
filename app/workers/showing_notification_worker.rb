class ShowingNotificationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(user_id, showing_id)
    user = User.find(user_id)
    showing = Showing.find(showing_id)
    to = user.profile.phone1

    # Todo: If needed, this should be done on save of the showing model, not here.
    # showing_url = Googl.shorten(users_showing_opportunity_path(showing_id))
    showing_url = users_showing_opportunity_url(showing_id)

    body = "New Showami showing available: #{showing_url}"
    log_msg = "Sending SMS showing notification to #{user.full_name} (#{user.profile.phone1}) -  New Showing: #{showing.address.single_line}"
    Rails.logger.tagged("Showing Notification SMS") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end
end
