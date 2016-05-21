module Users
  class ProfilesController < BaseController

    before_action :set_profile

    def edit

    end

    def update
      if current_user.profile.update(profile_params)
        redirect_to edit_users_profile_path, notice: "Profile successfully updated."
      else
        render :edit
      end
    end

    private

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :phone1, :phone2, :company, :agent_id, :agent_type)
    end

    def set_profile
      @profile = current_user.profile
    end

  end
end
