module Users
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def verify_valid_profile
      if current_user.profile.invalid?
        redirect_to edit_users_profile_path, notice: "Please fill out your profile before continuing."
      end
    end

    def verify_credit_card_on_file
      unless current_user.valid_credit_card?
        redirect_to users_cc_payment_path, notice: "Please fill out your credit card payment information before continuing."
      end
    end

    def verify_bank_token_on_file
      unless current_user.valid_bank_token?
        redirect_to users_bank_payment_path, notice: "Please fill out your bank information before continuing."
      end
    end
  end
end
