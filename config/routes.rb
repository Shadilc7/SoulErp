Rails.application.routes.draw do
  # Move this to the top, before any authenticate blocks
  get "/sections/fetch", to: "institute_admin/sections#fetch"

  # Root path first
  root "home#index"

  # Devise routes with custom paths
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register"
  }, controllers: {
    registrations: "registrations"
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
      root "admin#dashboard"
      resources :institutes do
        member do
          post "assign_admin"
          delete "unassign_admin"
        end
        resources :sections
      end
      resources :users
      resources :training_programs
      resources :assignments
      resource :registration_setting, only: [ :edit, :update ]
    end
  end

  # Institute Admin routes
  authenticate :user, lambda { |u| u.institute_admin? } do
    namespace :institute_admin do
      root "dashboard#index"
      resources :sections do
        collection do
          get :fetch
        end
        member do
          get :participants
        end
      end
      resources :trainers
      resources :participants
      resources :questions
      resources :question_sets
      resources :training_programs
      resources :assignments do
        resources :responses, only: [ :index, :show ]
      end
      resources :responses, only: [ :index, :show ]
    end
  end

  # Trainer Portal routes
  authenticate :user, lambda { |u| u.trainer? } do
    namespace :trainer_portal do
      root "dashboard#index"
      resources :training_programs do
        member do
          patch :update_progress
          patch :mark_completed
        end
        resources :sessions
      end
      resource :profile, only: [ :edit, :update ]
    end
  end

  # Participant routes
  authenticate :user, lambda { |u| u.participant? } do
    namespace :participant_portal do
      root "dashboard#index"
      resources :training_programs, only: [ :index, :show ] do
        resources :sessions, only: [ :show ]
      end
      resource :profile, only: [ :show, :edit, :update ]
      resources :assignments, only: [ :index, :show ] do
        member do
          get :take_assignment, as: :take
          post :submit
        end
      end
    end
  end
end
