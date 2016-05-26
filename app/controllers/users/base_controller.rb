module Users
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def verify_valid_profile
      if current_user.profile.invalid?
        redirect_to edit_users_profile_path, notice: "Please fill out your profile before continuing."
      end
    end
  end
end
