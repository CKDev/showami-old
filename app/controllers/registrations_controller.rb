class RegistrationsController < Devise::RegistrationsController
  layout "home", except: [:edit]
  layout "users/base", if: [:edit]
end
