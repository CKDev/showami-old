module Users
  class CcPaymentsController < BaseController

    before_action :verify_valid_profile

    def show

    end

    def create
      token = params[:stripeToken]
      if Payment::Customer.new(token, current_user).send
        redirect_to users_root_path, notice: "Thank you for adding your payment information, you may now schedule showings."
      else
        redirect_to users_root_path, alert: "There was an error adding payment information, please try again or <a href='/contact'>contact us</a>."
      end
    end

  end
end
