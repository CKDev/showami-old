module Users
  class ShowingOpportunitiesController < BaseController

    before_action :verify_valid_profile

    def index

    end

    def show
      @showing = Showing.find(params[:id])
    end

    def update
      @showing = Showing.find(params[:id])
      @showing.update(status: update_params)
      redirect_to users_showing_opportunities_path, notice: "Showing accepted"
    end

    private

    def update_params
      return "unconfirmed" if params[:commit] == "Accept"
      raise ArgumentError, "Unknown showing status: #{params[:commit]}"
    end
  end
end
