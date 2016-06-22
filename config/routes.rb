require "sidekiq/web"

Rails.application.routes.draw do

  namespace :users do
    root "profiles#edit"
    resource :profile, only: [:edit, :update] do
      member do
        post :delete_avatar
      end
    end
    resources :buyers_requests, except: [:edit, :update, :delete] do
      member do
        post :cancel
        post :no_show
      end
    end
    resources :showing_appointments, only: [:index] do
      member do
        post :confirm
        post :cancel
      end
    end
    resources :showing_opportunities, only: [:index, :show] do
      member do
        post :accept
      end
    end
    resource :cc_payment, only: [:show, :create]
    resource :bank_payment, only: [:show, :create]
  end

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:show, :index] do
      member do
        post :unblock
      end
    end
    resources :showings, only: [:show]
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

  # Webhooks (Stripe only, for now)
  post "webhook/receive"

  # Sidekiq web interface is a Sinatra app.
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

end
