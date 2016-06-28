module Payment
  class Charge

    def initialize(token, showing)
      @token = token
      @showing = showing
    end

    def send
      raise ArgumentError unless @token.present?
      raise ArgumentError unless @showing.present?

      Log::EventLogger.info(nil, @showing.id, "Charging card for showing.", "Showing: #{@showing.id}", "Stripe Charge")
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      charge = Stripe::Charge.create(
        amount: 4_000, # Amount in cents - $40
        currency: "usd",
        customer: @token,
        description: "Buyer's agent charge for a successfully completed showing: #{@showing}"
      )
      @showing.update(charge_txn: charge.id)
      Log::EventLogger.info(nil, @showing.id, "Charge successful.", "Showing: #{@showing.id}", "Stripe Charge")
      return true
    rescue Stripe::CardError => e
      Notification::ErrorReporter.send(e)
      Notification::Email.notify_admins("A credit card charge failed", "Showing: #{@showing.to_s}")
      Log::EventLogger.error(nil, @showing.id, "Charge error: #{e.code} - #{e.message}", "Showing: #{@showing.id}", "Stripe Charge")
      return false
    end

  end
end
