module Users
  class BuyersRequestsController < BaseController

    before_action :verify_valid_profile
    before_action :verify_credit_card_on_file, only: [:new, :create]
    before_action :verify_not_blocked, only: [:new, :create]

    def index
      @showings = current_user.showings
        .includes(:address, :showing_agent)
        .paginate(page: params[:page], per_page: 25)
    end

    def new
      @showing = Showing.new
      @showing.build_address
    end

    def create
      @showing = Showing.new(showing_params)
      @showing.user = current_user
      @showing.status = "unassigned_with_preferred" if @showing.preferred_agent.present?

      if @showing.save
        lat = @showing.address.latitude
        long = @showing.address.longitude
        matched_users = User.not_blocked.sellers_agents.not_self(current_user.id).in_bounding_box(lat, long)

        if @showing.preferred_agent.present?
          Log::EventLogger.info(current_user.id, @showing.id, "Notifying preferred agent of new showing", "User: #{current_user.id}", "Showing: #{@showing.id}", "Showing Notification SMS")
          if @showing.preferred_agent.in? matched_users
            @showing.preferred_agent.notify_new_preferred_showing(@showing)
          else
            PreferredAgentNotAMatchWorker.perform_async(@showing.id)
          end
        else
          Log::EventLogger.info(current_user.id, @showing.id, "Notifying #{matched_users.count} users of new showing", "User: #{current_user.id}", "Showing: #{@showing.id}", "Showing Notification SMS")
          matched_users.each do |u|
            u.notify_new_showing(@showing)
          end
        end
        redirect_to users_buyers_requests_path, notice: "New showing successfully created."
      else
        render :new
      end
    end

    def show
      @showing = current_user.showings.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to users_buyers_requests_path, alert: "No showing found with the given id."
    end

    def cancel
      @showing = current_user.showings.find(params[:id])
      if @showing.cancel_causes_payment?
        if @showing.update(status: "cancelled_with_payment")
          ShowingCancelledNotifyShowingAgentWorker.perform_async(@showing.id, true)
          redirect_to users_buyers_requests_path, notice: "Showing cancelled, payment will still be required."
        else
          redirect_to users_buyers_requests_path, alert: "Unable to mark showing as cancelled."
        end
      else
        if @showing.status != "cancelled" && @showing.update(status: "cancelled")
          ShowingCancelledNotifyShowingAgentWorker.perform_async(@showing.id, false)
          redirect_to users_buyers_requests_path, notice: "Showing cancelled, no payment will be required."
        else
          redirect_to users_buyers_requests_path, alert: "Unable to mark showing as cancelled."
        end
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to users_buyers_requests_path, alert: "No showing found with the given id."
    end

    def no_show
      @showing = current_user.showings.find(params[:id])
      if @showing.status != "no_show" && @showing.update(status: "no_show")
        @showing.showing_agent.update(blocked: true)
        ShowingAgentBlockedNotificationWorker.perform_async(@showing.id)
        redirect_to users_buyers_requests_path, notice: "Showing marked as a 'no-show'."
      else
        redirect_to users_buyers_requests_path, alert: "Unable to mark showing as a 'no-show'.  Has it been more than 24 hours since the showing time?"
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to users_buyers_requests_path, alert: "No showing found with the given id."
    end

    private

    def showing_params
      params["showing"]["preferred_agent_id"] = preferred_agent_id # This param comes in as a raw email.
      params.require(:showing).permit(:showing_at, :mls, :notes,
        :buyer_name, :buyer_phone, :buyer_type, :preferred_agent_id,
        address_attributes: [:id, :line1, :line2, :city, :state, :zip])
    end

    def preferred_agent_id
      preferred_agent_email = params["showing"]["preferred_agent"]
      preferred_agent = User.find_by_email(preferred_agent_email)
      preferred_agent.id
    rescue
      # TODO: this doesn't seem like the best place for this.
      UserMailer.invite(preferred_agent_email).deliver_later if preferred_agent_email.present?
      ""
    end

  end
end
