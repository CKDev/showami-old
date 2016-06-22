module Admin
  class UsersController < BaseController

    def index
      @users = User.all
    end

    def show
      @user = User.find(params[:id])
      @events = @user.event_logs
    end

    def unblock
      @user = User.find(params[:id])
      if @user.update(blocked: false)
        redirect_to admin_user_path(@user), notice: "Successfully unblocked #{@user}."
      else
        redirect_to admin_user_path(@user), alert: "Unable to unblock #{@user}."
      end
    end

  end
end
