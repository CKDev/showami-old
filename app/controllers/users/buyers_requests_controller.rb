module Users
  class BuyersRequestsController < BaseController

    before_action :verify_valid_profile

    def index
      @showings = current_user.showings
        .includes(:address)
        .paginate(page: params[:page])
    end

    def new
      @showing = Showing.new
      @showing.build_address
    end

    def create
      @showing = Showing.new(showing_params)
      @showing.user = current_user

      if @showing.save
        lat = @showing.address.latitude
        long = @showing.address.longitude
        matched_users = User.sellers_agents.not_self(current_user.id).in_bounding_box(lat, long)
        Rails.logger.tagged("Showing Notification SMS") { Rails.logger.info "Notifying #{matched_users.count} users of new showing: #{@showing.address.single_line}" }
        matched_users.each do |u|
          u.notify_new_showing(@showing)
        end
        redirect_to users_buyers_requests_path, notice: "New showing successfully created."
      else
        render :new
      end
    end

    def show
      @showing = Showing.find(params[:id])
    end

    def cancel
      @showing = Showing.find(params[:id])
      @showing.update(status: "cancelled")
      redirect_to users_buyers_requests_path, notice: "Showing cancelled."
    end

    private

    def showing_params
      params.require(:showing).permit(:showing_at, :mls, :notes,
        :buyer_name, :buyer_phone, :buyer_type,
        address_attributes: [:id, :line1, :line2, :city, :state, :zip])
    end

  end
end
