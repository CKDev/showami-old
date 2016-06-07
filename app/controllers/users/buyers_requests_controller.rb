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
        User.sellers_agents.not_self(current_user.id).in_bounding_box(lat, long).each do |u|
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

    private

    def showing_params
      params.require(:showing).permit(:showing_at, :mls, :notes,
        :buyer_name, :buyer_phone, :buyer_type,
        address_attributes: [:id, :line1, :line2, :city, :state, :zip])
    end

  end
end
