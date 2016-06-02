require "twilio-ruby"

module Notification

  class SMS

    def initialize(to, body, override = false)
      @to = to
      @from = Rails.application.secrets.twilio_default_from
      @body = body
      @client = Twilio::REST::Client.new

      # Only certain "magic" numbers work with test credentials.
      @to = "+15005550006" if (Rails.env.development? || Rails.env.test?) && override == false
    end

    def send
      @client.messages.create(body: @body, to: @to, from: @from)
      log_msg = "Completed SMS showing notification to #{@to}"
      Rails.logger.tagged("SMS (Twilio)") { Rails.logger.info log_msg }
    rescue Twilio::REST::RequestError => e
      Rails.logger.tagged("SMS (Twilio)") { Rails.logger.error "Error: #{e.code} - #{e.message}" }
    end

  end

end
