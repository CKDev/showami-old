Rails.application.routes.draw do

  namespace :users do
    root "dashboard#index"
  end

  namespace :admin do
    root "dashboard#index"
  end

  devise_for :users
  root to: "home#index"
end
