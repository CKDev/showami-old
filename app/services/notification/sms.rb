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
      Rails.logger.tagged("Showing Notification SMS") { Rails.logger.info log_msg }
      Rails.logger.tagged("Showing Notification SMS") { Rails.logger.error "Previous message was > 140 characters" } if @body.length > 140
    rescue Twilio::REST::RequestError => e
      Notification::ErrorReporter.send(e)
      Rails.logger.tagged("Showing Notification SMS") { Rails.logger.error "Error: #{e.code} - #{e.message}" }
    end

  end

end
