module Admin
  class ShowingsController < BaseController

    def show
      @showing = Showing.find(params[:id])
      @events = @showing.event_logs
    end

  end
end
