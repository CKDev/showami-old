module Users
  class DashboardController < BaseController
    before_action :verify_valid_profile

    def index

    end

  end
end
