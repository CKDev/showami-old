class RegistrationsController < Devise::RegistrationsController
  layout proc { user_signed_in? ? "users/base" : "home" }
end
