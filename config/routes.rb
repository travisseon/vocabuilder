Rails.application.routes.draw do
  root "dashboard#index"
  
  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  
  # User routes
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/profile", to: "users#show"
  
  # Dashboard
  get "/dashboard", to: "dashboard#index"
  
  # Learning routes
  resources :decks, only: [:index, :show] do
    resources :sentences, only: [:show] do
      member do
        post :check_answer
        post :complete
        get :sentence_data
      end
    end
  end
  
  # Review routes
  resources :reviews, only: [:index, :show] do
    member do
      post :check_answer
      post :complete
    end
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
