module Users
  class CcPaymentsController < BaseController

    before_action :verify_valid_profile

    def show

    end

    def create
      Stripe.api_key = Rails.application.secrets[:stripe]["private_key"]
      token = params[:stripeToken]
      customer = Stripe::Customer.create(source: token, email: current_user.email)
      current_user.profile.update(cc_token: customer.id)
      Rails.logger.tagged("User: #{current_user.id}", "Create Stripe Customer") { Rails.logger.error "Successfully created Stripe customer account for #{current_user}" }
      redirect_to users_root_path, notice: "Thank you for adding your payment information, you may now schedule showings."
    rescue Stripe::CardError => e
      Notification::ErrorReporter.send(e)
      Rails.logger.tagged("User: #{current_user.id}", "Create Stripe Customer") { Rails.logger.error "Error creating credit card information for #{current_user}: #{e.message} (#{e.code})" }
      redirect_to users_root_path, alert: e.message
    end

  end
end
