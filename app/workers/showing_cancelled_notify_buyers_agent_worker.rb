class ShowingCancelledNotifyBuyersAgentWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options queue: "high"

  def perform(showing_id)
    showing = Showing.find(showing_id)
    to = showing.user.profile.phone1
    body = "Your showing request was cancelled: #{showing.address}.  For more details visit: #{users_buyers_requests_url}"
    log_msg = "Sending SMS showing cancelled notification to #{showing.user.full_name} (#{showing.buyers_agent_phone}) - #{body}"
    Rails.logger.tagged("Showing: #{showing.id}", "Showing Cancelled Buyers Agent Notification SMS") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end
end
