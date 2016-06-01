class PasswordsController < Devise::PasswordsController
  layout proc { user_signed_in? ? "users/base" : "home" }
end
