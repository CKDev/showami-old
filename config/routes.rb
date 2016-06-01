require "sidekiq/web"

Rails.application.routes.draw do

  namespace :users do
    root "dashboard#index"
    resource :profile, only: [:edit, :update] do
      member do
        post :delete_avatar
      end
    end
    resources :buyers_requests
    resources :showing_appointments
    resources :showing_opportunities
  end

  namespace :admin do
    root "dashboard#index"
  end

  devise_for :users, controllers: {
    sessions: "sessions",
    registrations: "registrations",
    passwords: "passwords"
  }

  root to: "home#index"

  # Static pages
  get "about", to: "about#show"
  get "terms", to: "terms#show"
  get "privacy", to: "privacy#show"
  get "contact", to: "contact#show"

  # Sidekiq web interface is a Sinatra app.
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

end
