Rails.application.routes.draw do
  resources :conversations, only: [ :index, :show, :destroy ] do
    member do
      post :generate_response
      post :send_reply
      patch :toggle_status
    end
    collection do
      post :fetch_emails
    end
  end
  resources :personas do
    collection do
      post :generate_random
      post :test
    end
  end
  resources :email_accounts, except: [ :show ]
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "email_accounts#index"
end
