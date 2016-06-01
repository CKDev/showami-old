class RegistrationsController < Devise::RegistrationsController
  layout "home", except: [:edit]
end
