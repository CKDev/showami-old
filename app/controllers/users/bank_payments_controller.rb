module Users
  class BankPaymentsController < BaseController

    before_action :verify_valid_profile

    def show

    end

    def create
      # # TODO: move this to model and background job?
      # Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      # token = params[:stripeToken]
      # customer = Stripe::Customer.create(source: token, email: current_user.email)
      # current_user.profile.update(cc_token: customer.id)
      # redirect_to users_root_path, notice: "Thank you for adding your payment information, you may now schedule showings."
    rescue => e
      # Notification::ErrorReporter.send(e)
      # Rails.logger.tagged("Stripe Create Payment") { Rails.logger.error "Error creating subscription for #{current_user.email}: #{e.message}" }
      # redirect_to users_root_path, alert: "An error occurred creating your subscription, we're looking into the situation."
    end

  end
end
