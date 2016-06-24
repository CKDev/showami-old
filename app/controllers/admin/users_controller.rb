module Admin
  class UsersController < BaseController

    def index
      @users = User.includes(:profile)
        .not_admin.order_by_first_name
        .paginate(page: params[:page], per_page: 25)
    end

    def show
      @user = User.includes(:event_logs).find(params[:id])
    end

    def unblock
      @user = User.find(params[:id])
      if @user.update(blocked: false)
        redirect_to admin_user_path(@user), notice: "Successfully unblocked #{@user}."
      else
        redirect_to admin_user_path(@user), alert: "Unable to unblock #{@user}."
      end
    end

    def block
      @user = User.find(params[:id])
      if @user.update(blocked: true)
        redirect_to admin_user_path(@user), notice: "Successfully blocked #{@user}."
      else
        redirect_to admin_user_path(@user), alert: "Unable to block #{@user}."
      end
    end

    def confirm
      @user = User.find(params[:id])
      if @user.update(confirmed_at: Time.zone.now)
        redirect_to admin_user_path(@user), notice: "Successfully confirmed #{@user}."
      else
        redirect_to admin_user_path(@user), alert: "Unable to confirm #{@user}."
      end
    end

  end
end
