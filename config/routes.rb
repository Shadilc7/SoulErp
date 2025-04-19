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
  authenticate :user do
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
  authenticate :user do
    namespace :institute_admin do
      root "dashboard#index"
      
      # Add profile routes
      get 'profile', to: 'profile#show'
      
      # Add settings routes
      resources :settings, only: [:index]
      get 'general_settings', to: 'general_settings#index', as: 'general_settings'
      patch 'general_settings', to: 'general_settings#update'
      
      resources :sections do
        member do
          get :reassign_users
          post :reassign_users
          get :participants
        end
      end

      resources :trainers
      resources :participants
      resources :questions do
        member do
          post :duplicate
        end
      end
      resources :question_sets
      resources :training_programs do
        resources :training_program_feedbacks, only: [:index], path: 'feedbacks'
        resources :attendances, only: [:index, :new, :create]
        member do
          patch :update_status
          patch :update_progress
          patch :mark_completed
        end
      end
      resources :attendances, only: [:index] do
        collection do
          get :list
          get :export_history_csv
          get :export_status_csv
        end
        member do
          get :mark
          post :record
          get :edit
          patch :update
          get :history
          get :check_status
        end
      end
      resources :assignments do
        resources :responses, only: [ :index, :show ]
      end
      resources :responses do
        get "section/:section_id", action: :index, on: :collection
        get "section/:section_id/participant/:participant_id", action: :index, on: :collection
      end
      resources :reports, only: [:index] do
        collection do
          get 'assignment_reports'
          get 'feedback_reports'
          get 'certificates'
        end
      end
    end
  end

  # Trainer Portal routes
  authenticate :user do
    namespace :trainer_portal do
      root "dashboard#index"
      
      # Add profile routes
      get 'profile', to: 'profile#show'
      
      resources :training_programs do
        resources :attendances, only: [:index, :new, :create]
        member do
          patch :update_status
          patch :update_progress
          patch :mark_completed
        end
      end
      
      resources :attendances, only: [:index] do
        collection do
          get :list
          get :export_history_csv
          get :export_status_csv
        end
        member do
          get :mark
          post :record
          get :edit
          patch :update
          get :history
          get :check_status
        end
      end
      
      resources :training_program_feedbacks, only: [:index, :show], path: 'feedbacks'
    end
  end

  # Participant routes
  authenticate :user do
    namespace :participant_portal do
      root "dashboard#index"
      resources :training_programs, only: [ :index, :show ] do
        resources :sessions, only: [ :show ]
        resources :feedbacks, only: [ :new, :create ], controller: "training_program_feedbacks"
      end
      resources :assignments, only: [ :index, :show ] do
        member do
          get :take_assignment
          post :submit
        end
      end
      resource :profile, only: [ :show ]
      get 'my_student', to: 'profiles#student_info', as: :student_info
    end
  end
end
