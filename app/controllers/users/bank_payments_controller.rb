module Users
  class BankPaymentsController < BaseController

    before_action :verify_valid_profile

    def show

    end

    def create
      # TODO: move this to model and background job?
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      token = params[:stripeToken]
      recipient = Stripe::Recipient.create(
        name: current_user.profile.full_name,
        type: "individual",
        email: current_user.email,
        bank_account: token
      )
      current_user.profile.update(bank_token: recipient.id)
      redirect_to users_root_path, notice: "Thank you for adding your payment information, you may accept showing invitations."
    rescue => e
      Notification::ErrorReporter.send(e)
      Rails.logger.tagged("Stripe Create Bank Account") { Rails.logger.error "Error creating bank token for #{current_user.email}: #{e.message}" }
      redirect_to users_root_path, alert: "An error occurred creating your bank token, we're looking into the situation."
    end

  end
end
