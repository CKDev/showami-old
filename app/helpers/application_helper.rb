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

end
