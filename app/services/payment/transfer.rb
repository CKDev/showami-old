module Payment
  class Transfer

    def initialize(token, showing)
      @token = token
      @showing = showing
    end

    def send
      raise ArgumentError unless @token.present?
      raise ArgumentError unless @showing.present?

      Log::EventLogger.info(nil, @showing.id, "Attempting payment transfer...", "Showing: #{@showing.id}", "Stripe Transfer")
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      transfer = Stripe::Transfer.create(
        amount: 4_000, # Amount in cents - $40
        currency: "usd",
        recipient: @token,
        statement_descriptor: "Seller's agent payment transfer for a successfully completed showing: #{@showing}"
      )
      @showing.update(transfer_txn: transfer.id)
      Log::EventLogger.info(nil, @showing.id, "Transfer initiated.", "Showing: #{@showing.id}", "Stripe Transfer")
      return true
    rescue Stripe::StripeError => e
      Notification::ErrorReporter.send(e)
      Log::EventLogger.error(nil, @showing.id, "Transfer error: #{e}", "Showing: #{@showing.id}", "Stripe Transfer")
      return false
    end

  end
end
