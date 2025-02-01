Rails.application.routes.draw do
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register"
  }, skip: [ :sessions ]  # Skip sessions routes

  # Custom session routes
  devise_scope :user do
    get "/" => "home#index", as: :new_user_session
    post "login" => "devise/sessions#create", as: :user_session
    delete "logout" => "devise/sessions#destroy", as: :destroy_user_session
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Admin routes
  authenticate :user, lambda { |u| u.master_admin? } do
    namespace :admin do
      root to: "admin#dashboard"
      get "dashboard", to: "admin#dashboard"
      resources :institutes do
        member do
          post "assign_admin"
          delete "unassign_admin"
        end
        resources :users, only: [ :new, :create, :index ]
      end
      resources :users
    end
  end

  # Default root path
  root "home#index"

  # Add any additional routes below
end
