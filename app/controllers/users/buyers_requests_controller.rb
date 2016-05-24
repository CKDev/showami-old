module Users
  class BuyersRequestsController < BaseController

    def index

    end

    def new
      @showing = Showing.new
      @showing.build_address
    end

    def create
      @showing = Showing.new(showing_params)
      if @showing.save
        redirect_to users_buyers_requests_path, notice: "New showing successfully created."
      else
        render :new
      end
    end

    private

    def showing_params
      params.require(:showing).permit(:showing_date, :mls, :notes,
        address_attributes: [:id, :line1, :line2, :city, :state, :zip])
    end

  end
end
