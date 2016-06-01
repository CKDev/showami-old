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

  def add_active_link(path, classes="")
    if current_page? path
      "#{classes} active"
    else
      classes
    end
  end

end
