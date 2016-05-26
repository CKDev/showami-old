class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_greeting

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.admin?
    resource.profile.valid? ? users_root_path : edit_users_profile_path
  end

  def set_greeting
    if user_signed_in?
      @greeting ||= current_user.greeting
    end
  end
end
