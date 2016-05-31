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
        User.in_bounding_box(@showing.address.latitude, @showing.address.longitude).each do |u|
          u.notify_new_showing(@showing)
        end
        redirect_to users_buyers_requests_path, notice: "New showing successfully created."
      else
        render :new
      end
    end

    private

    def showing_params
      params.require(:showing).permit(:showing_at, :mls, :notes,
        :buyer_name, :buyer_phone, :buyer_type,
        address_attributes: [:id, :line1, :line2, :city, :state, :zip])
    end

  end
end
