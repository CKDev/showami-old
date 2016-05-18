module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def authenticate_admin!
      redirect_to root_path, alert: "Access denied!" unless current_user.admin
    end
  end
end
