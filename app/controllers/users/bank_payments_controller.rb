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
      log_msg = "Error creating bank token: #{e.message}"
      Log::EventLogger.error(current_user.id, nil, log_msg, "Create Bank Token")
      redirect_to users_root_path, alert: "An error occurred creating your bank token."
    end

  end
end
