Rails.application.routes.draw do
  # Devise routes
  devise_for :users

  # Root path
  root "home#index"

  # Authenticated routes
  authenticated :user do
    get "dashboard", to: "home#dashboard"
  end

  # Resources
  resources :items do
    member do
      post :try_on
    end
  end
  resources :outfit_suggestions, only: [:index, :show] do
    collection do
      post :generate
    end
  end
  resource :profile, only: [:show, :edit, :update]

  # Partner/B2B routes
  resources :partners do
    member do
      get :dashboard
      post :renew_subscription
      post :suspend_subscription
    end
  end

  # B2B API routes
  namespace :api do
    namespace :v1 do
      post "virtual-try-on", to: "virtual_try_on#create"
      resources :partners, only: [:index, :show, :create]
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
