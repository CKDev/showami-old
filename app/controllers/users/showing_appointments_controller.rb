module Users
  class ShowingAppointmentsController < BaseController

    before_action :verify_valid_profile

    def index
      @showings = Showing.where(showing_agent: current_user).paginate(page: params[:page])
    end

  end
end
