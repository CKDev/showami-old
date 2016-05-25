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

    def delete_avatar
      current_user.profile.avatar.destroy
      current_user.profile.avatar = nil
      current_user.profile.save
      redirect_to edit_users_profile_path, notice: "Avatar successfully removed."
    end

    private

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :phone1, :phone2,
        :company, :agent_id, :agent_type, :avatar, :geo_box)
    end

    def set_profile
      @profile = current_user.profile
    end

  end
end
