class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit # To make current_user available to model auditing

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource) # This resets after being called, so store.
    return admin_root_path if resource.admin?
    return edit_users_profile_path if resource.profile.invalid?
    return stored_location if stored_location
    return users_showing_appointments_path if resource.profile.agent_type == "sellers_agent"
    users_buyers_requests_path
  end

end
