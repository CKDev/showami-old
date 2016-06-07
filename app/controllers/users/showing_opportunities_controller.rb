module Users
  class ShowingOpportunitiesController < BaseController

    before_action :verify_valid_profile

    def index
      @showings = Showing.available(current_user.profile.geo_box_coords).paginate(page: params[:page])
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
