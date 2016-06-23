module Users
  class ShowingAppointmentsController < BaseController

    before_action :verify_valid_profile

    def index
      @showings = Showing.includes(:showing_agent, :address)
        .where(showing_agent: current_user)
        .paginate(page: params[:page], per_page: 25)
    end

    def confirm
      @showing = Showing.find(params[:id])
      if @showing.status != "confirmed" && @showing.update(status: "confirmed")
        ShowingConfirmedNotificationWorker.perform_async(@showing.id)
        redirect_to users_showing_appointments_path, notice: "Showing confirmed."
      else
        redirect_path = request.env["HTTP_REFERER"] || users_showing_appointments_path
        redirect_to redirect_path, alert: "Unable to confirm showing."
        Notification::ErrorReporter.send(StandardError.new("Unable to confirm showing."))
      end
    end

    def cancel
      @showing = Showing.find(params[:id])
      if @showing.update(status: "cancelled")
        ShowingCancelledNotifyBuyersAgentWorker.perform_async(@showing.id)
        redirect_to users_showing_appointments_path, notice: "Showing cancelled."
      else
        redirect_path = request.env["HTTP_REFERER"] || users_showing_appointments_path
        redirect_to redirect_path, alert: "Unable to cancel showing, please try again."
        Notification::ErrorReporter.send(StandardError.new("Unable to cancel showing."))
      end
    end

  end
end
