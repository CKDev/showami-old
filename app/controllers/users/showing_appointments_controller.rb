module Users
  class ShowingAppointmentsController < BaseController

    before_action :verify_valid_profile

    def index
      @showings = Showing.includes(:showing_agent, :address)
        .where(showing_agent: current_user)
        .paginate(page: params[:page])
    end

    def confirm
      @showing = Showing.find(params[:id])
      @showing.update(status: "confirmed")
      redirect_to users_showing_appointments_path, notice: "Showing confirmed."
    end

    def cancel
      @showing = Showing.find(params[:id])
      @showing.update(status: "cancelled")
      redirect_to users_showing_appointments_path, notice: "Showing cancelled."
    end

  end
end
