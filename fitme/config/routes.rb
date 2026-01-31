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

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
