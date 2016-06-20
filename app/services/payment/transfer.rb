module Payment
  class Transfer

    def initialize(token, showing)
      @token = token
      @showing = showing
    end

    def send
      Rails.logger.tagged("Showing: #{@showing.id}", "Stripe Transfer") { Rails.logger.info "Attempting payment transfer..." }
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      transfer = Stripe::Transfer.create(
        amount: 4_000, # Amount in cents - $40
        currency: "usd",
        recipient: @token,
        statement_descriptor: "Seller's agent payment transfer for a successfully completed showing: #{@showing}"
      )
      @showing.update(transfer_txn: transfer.id)
      Rails.logger.tagged("Showing: #{@showing.id}", "Stripe Transfer") { Rails.logger.info "Transfer initiated." }
      return true
    rescue StandardError => e
      Rails.logger.tagged("Showing: #{@showing.id}", "Stripe Transfer") { Rails.logger.error "Transfer error: #{e}" }
      return false
    end

  end
end
