module Users
  class BankPaymentsController < BaseController

    before_action :verify_valid_profile

    def show

    end

    def create
      token = params[:stripeToken]
      if Payment::Recipient.new(token, current_user).send
        redirect_to users_root_path, notice: "Thank you for adding your payment information, you may accept showing invitations."
      else
        redirect_to users_root_path, alert: "There was an error adding payment information, please try again or contact us."
      end
    end

  end
end
