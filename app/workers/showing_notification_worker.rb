class ShowingNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(user_id, showing_id)
    user = User.find(user_id)
    showing = Showing.find(showing_id)
    to = user.profile.phone1
    body = "There is a new showing available at: #{showing.address.single_line}"
    log_msg = "Sending SMS showing notification to #{user.full_name} (#{user.profile.phone1}) -  New Showing: #{showing.address.single_line}"
    Rails.logger.tagged("Showing Notification SMS") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end
end
