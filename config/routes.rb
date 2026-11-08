Rails.application.routes.draw do
  get "home/index"
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Web UI auth (session-based)
  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create", as: :session
  delete "logout", to: "sessions#destroy", as: :destroy_session

  get "password/change", to: "passwords#edit", as: :edit_password
  patch "password/change", to: "passwords#update", as: :password

  # API v1 namespace (JSON for mobile + web)
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Auth
      post "auth/login", to: "auth#login"
      post "auth/logout", to: "auth#logout"
      post "auth/password-change", to: "auth#password_change"

      # Sync
      post "sync", to: "sync#upload"
      get  "sync", to: "sync#download"

      # System configs (ADMIN write, all read)
      get "system_configs", to: "system_configs#index"
      get "system_configs/:key", to: "system_configs#show"
      post "system_configs", to: "system_configs#create"
      patch "system_configs/:key", to: "system_configs#update"
      delete "system_configs/:key", to: "system_configs#destroy"

      # Resources
      resources :clients, only: %i[index show create update destroy]
      resources :savings_accounts, only: %i[index show create update destroy]
      resources :savings_transactions, only: %i[index show create]
      resources :loans, only: %i[index show create update destroy]
      resources :loan_repayments, only: %i[index show create]
      resources :group_accounts, only: %i[index show]
      resources :group_transactions, only: %i[index show create]
      resources :audit_logs, only: %i[index]
    end
  end

  # Web UI resources (session-authenticated, HTML). Separate from /api/v1/*.
  resources :clients
  resources :loans
  resources :savings_accounts
  resources :savings_transactions, only: %i[index show new create]
  resources :loan_repayments, only: %i[index show new create]
  resources :group_accounts
  resources :group_transactions, only: %i[index show new create]
  resources :audit_logs, only: [ :index ]
  resources :system_configs, param: :config_key

  # Root
  root "home#index"
end
