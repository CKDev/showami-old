module Users
  class ShowingOpportunitiesController < BaseController

    before_action :verify_valid_profile

    def index
      @showings = Showing.available(current_user.profile.geo_box_coords).paginate(page: params[:page])
    end

    def show
      @showing = Showing.find(params[:id])
    end

    def accept
      @showing = Showing.find(params[:id])
      @showing.update(status: "unconfirmed", showing_agent: current_user)
      ShowingAcceptedNotificationWorker.perform_async(@showing.id)
      redirect_to users_showing_appointments_path, notice: "Showing accepted"
    end

  end
end
