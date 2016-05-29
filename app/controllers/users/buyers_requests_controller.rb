module Users
  class BuyersRequestsController < BaseController

    before_action :verify_valid_profile

    def index
      # TODO: change paging size back to 25 once done with testing.
      @showings = current_user.showings
        .includes(:address)
        .paginate(page: params[:page], per_page: 2)
    end

    def new
      @showing = Showing.new
      @showing.build_address
    end

    def create
      @showing = Showing.new(showing_params)
      @showing.user = current_user
      if @showing.save
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
