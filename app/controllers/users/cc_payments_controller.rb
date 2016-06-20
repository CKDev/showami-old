module Users
  class CcPaymentsController < BaseController

    before_action :verify_valid_profile

    def show

    end

    def create
      # TODO: move this to model and background job?
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      token = params[:stripeToken]
      customer = Stripe::Customer.create(source: token, email: current_user.email)
      current_user.profile.update(cc_token: customer.id)
      Rails.logger.tagged("User: #{current_user.id}", "Create Stripe Customer") { Rails.logger.error "Successfully created Stripe customer account for #{current_user}" }
      redirect_to users_root_path, notice: "Thank you for adding your payment information, you may now schedule showings."
    rescue => e
      Notification::ErrorReporter.send(e)
      Rails.logger.tagged("User: #{current_user.id}", "Create Stripe Customer") { Rails.logger.error "Error creating payment information for #{current_user}: #{e.message}" }
      redirect_to users_root_path, alert: "An error occurred creating your payment information, we're looking into the situation."
    end

  end
end
