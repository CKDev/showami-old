require "twilio-ruby"

module Notification

  class SMS

    def initialize(to, body, override = false)
      @to = to
      @from = Rails.application.secrets.twilio_default_from
      @body = body
      @client = Twilio::REST::Client.new

      # Only certain "magic" numbers work with test credentials.
      @to = "+15005550006" if (Rails.env.development? || Rails.env.test?) && override == true
    end

    def send
      @client.messages.create(body: @body, to: @to, from: @from)
    rescue Twilio::REST::RequestError => e
      Rails.logger.error "(Twilio Error: #{e.code}) #{e.message}"
    end

  end

end
