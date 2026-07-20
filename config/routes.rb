Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "up/db" => "db_health#show", as: :db_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  mount ActionCable.server => "/cable"
  root "projects#index"
  resource :profile, only: %i[show], controller: "profile"

  resources :client_notifications, only: %i[update]
  resources :notifications, only: %i[update]

  resources :projects, only: %i[index show new edit update] do
    member do
      patch :accept
      patch :complete
    end

    resources :comments, only: %i[create]
  end
end
