module Payment
  class Charge

    def initialize(token, showing)
      @token = token
      @showing = showing
    end

    def send
      Rails.logger.tagged("Stripe Charge") { Rails.logger.info "Charging card for showing: #{@showing}" }
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      charge = Stripe::Charge.create(
        amount: 5_000, # Amount in cents - $50
        currency: "usd",
        customer: @token,
        description: "Buyer's agent charge for a successfully completed showing: #{@showing}"
      )
      # TODO: what to do with the charge response?
      Rails.logger.tagged("Stripe Charge") { Rails.logger.info "Charge successful" }
      return true
    rescue Stripe::CardError => e
      Rails.logger.tagged("Stripe Charge") { Rails.logger.error "Error: #{e.code} - #{e.message}" }
      return false
    end

  end
end
