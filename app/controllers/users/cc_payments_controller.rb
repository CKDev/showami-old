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
      Log::EventLogger.info(current_user.id, nil, "Successfully created Stripe customer account", "User: #{current_user.id}", "Create Stripe Customer")
      redirect_to users_root_path, notice: "Thank you for adding your payment information, you may now schedule showings."
    rescue Stripe::CardError => e
      Notification::ErrorReporter.send(e)
      Log::EventLogger.error(current_user.id, nil, "Error creating Stripe customer account: #{e.message} (#{e.code})", "User: #{current_user.id}", "Create Stripe Customer")
      redirect_to users_root_path, alert: e.message
    end

  end
end
