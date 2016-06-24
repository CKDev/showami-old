module Payment
  class Recipient

    def initialize(token, user)
      @token = token
      @user = user
    end

    def send
      raise ArgumentError unless @token.present?
      raise ArgumentError unless @user.present?

      Log::EventLogger.info(@user.id, nil, "Creating Stripe Recipient Account...", "User: #{@user.id}", "Stripe Recipient")
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      recipient = Stripe::Recipient.create(
        name: @user.full_name,
        type: "individual",
        email: @user.email,
        bank_account: @token
      )
      @user.profile.update(bank_token: recipient.id)
      Log::EventLogger.info(@user.id, nil, "Creating Stripe Recipient Account successful.", "User: #{@user.id}", "Stripe Recipient")
      return true
    rescue Stripe::StripeError => e
      Notification::ErrorReporter.send(e)
      Log::EventLogger.error(@user.id, nil, "Stripe error: #{e} - #{e.message}", "User: #{@user.id}", "Stripe Recipient")
      return false
    end

  end
end
