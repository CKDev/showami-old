module ApplicationHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def add_active_link(paths, classes = "")
    paths.each do |path|
      if current_page? path
        return "#{classes} active"
      end
    end
    classes
  end

  def buyers_requests_route?
    return true if controller.controller_name == "buyers_requests"
    false
  end

  def showing_appointments_route?
    return true if controller.controller_name == "showing_appointments"
    false
  end

  def showing_opportunities_route?
    return true if controller.controller_name == "showing_opportunities"
    false
  end

  def tel_to(number)
    link_to number, "tel:#{number}"
  end

end
