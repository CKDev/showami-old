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
      if @showing.update(status: "confirmed")
        ShowingConfirmedNotificationWorker.perform_async(@showing.id)
        redirect_to users_showing_appointments_path, notice: "Showing confirmed."
      else
        redirect_path = request.env["HTTP_REFERER"] || users_showing_appointments_path
        redirect_to redirect_path, alert: "Unable to confirm showing, please try again."
      end
    end

    def cancel
      @showing = Showing.find(params[:id])
      @showing.update(status: "cancelled")
      redirect_to users_showing_appointments_path, notice: "Showing cancelled."
    end

  end
end
