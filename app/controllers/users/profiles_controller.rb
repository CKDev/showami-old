module Users
  class ProfilesController < BaseController

    before_action :set_profile

    def edit

    end

    def update
      if current_user.profile.update(profile_params)
        redirect_to redirect_path_after_update, notice: "Profile successfully updated."
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
        :company, :agent_id, :agent_type, :avatar, :geo_box, :geo_box_zoom)
    end

    def set_profile
      @profile = current_user.profile
    end

    def redirect_path_after_update
      current_user.profile.reload
      agent_type = current_user.profile.agent_type
      if agent_type == "buyers_agent" && !current_user.valid_credit_card?
        return users_cc_payment_path
      elsif agent_type == "sellers_agent" && !current_user.valid_bank_token?
        return users_bank_payment_path
      elsif agent_type == "both" && !current_user.valid_credit_card?
        return users_cc_payment_path
      elsif agent_type == "both" && !current_user.valid_bank_token?
        return users_bank_payment_path
      else
        return edit_users_profile_path
      end
    end

  end
end
