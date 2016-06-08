require "sidekiq/web"

Rails.application.routes.draw do

  namespace :users do
    root "profile#edit"
    resource :profile, only: [:edit, :update] do
      member do
        post :delete_avatar
      end
    end
    resources :buyers_requests, except: [:edit, :update, :delete] do
      member do
        post :cancel
      end
    end
    resources :showing_appointments, only: [:index]
    resources :showing_opportunities, only: [:index, :show] do
      member do
        post :accept
      end
    end
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
