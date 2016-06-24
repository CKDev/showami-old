module Payment
  class Customer

    def initialize(token, user)
      @token = token
      @user = user
    end

    def send
      raise ArgumentError unless @token.present?
      raise ArgumentError unless @user.present?

      Log::EventLogger.info(@user.id, nil, "Creating Stripe Customer Account...", "User: #{@user.id}", "Stripe Customer")
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      customer = Stripe::Customer.create(
        source: @token,
        email: @user.email
      )
      @user.profile.update(cc_token: customer.id)
      Log::EventLogger.info(@user.id, nil, "Creating Stripe Customer Account successful.", "User: #{@user.id}", "Stripe Customer")
      return true
    rescue Stripe::StripeError => e
      Notification::ErrorReporter.send(e)
      Log::EventLogger.error(@user.id, nil, "Stripe error: #{e} - #{e.message}", "User: #{@user.id}", "Stripe Customer")
      return false
    end

  end
end
