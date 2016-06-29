module Users
  class BankPaymentsController < BaseController

    before_action :verify_valid_profile
    before_action :set_redirect_path, only: [:show]

    def show

    end

    def create
      token = params[:stripeToken]
      if Payment::Recipient.new(token, current_user).send
        redirect_to redirect_path, notice: "Thank you for adding your payment information, you may accept showing invitations."
      else
        redirect_to users_root_path, alert: "There was an error adding payment information, please try again or <a href='/contact'>contact us</a>."
      end
    end

    private

    # Note: the below two methods work together to take the user back to where they were before adding their
    # payment info (if from a showing url).  Otherwise the user is put back on their profile page, which is
    # confusing if they were trying to book a showing, but were forced to enter bank info.

    def redirect_path
      saved_redirect_path = session[:after_successful_bank_update_path] || users_root_path
      session.delete(:after_successful_bank_update_path)
      saved_redirect_path
    end

    def set_redirect_path
      if Rails.application.routes.recognize_path(request.referrer)[:controller] == "users/showing_opportunities"
        session[:after_successful_bank_update_path] = request.referrer
      end
    rescue
      session.delete(:after_successful_bank_update_path) # Don't ever break for a simple UX improvement.
    end
  end
end
