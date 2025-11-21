# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Authentication (assuming Devise or similar)
  # devise_for :users

  # Main terminal interface
  root 'terminal#show'

  # Terminal routes
  get 'terminal', to: 'terminal#show', as: :terminal
  get 'terminal/new', to: 'terminal#new', as: :new_terminal_session
  post 'terminal/create', to: 'terminal#create', as: :create_terminal_session

  # API endpoints for terminal
  namespace :api do
    namespace :v1 do
      # Session management
      resources :terminal_sessions, only: [:create, :show, :update] do
        member do
          post :message
          get :state
          get :history
        end

        # Pending actions
        resources :pending_actions, only: [:index] do
          collection do
            post :approve
            post :reject
            post :batch_approve
          end
        end
      end

      # Character endpoints
      resources :characters, only: [:show, :update] do
        member do
          get :inventory
          get :spells
          post :rest
        end
      end

      # Combat endpoints
      resources :combats, only: [:show] do
        member do
          post :next_turn
          post :end_combat
        end
      end

      # Dice rolling
      post 'roll', to: 'dice#roll'

      # Map endpoints
      resources :dungeon_maps, only: [:show, :create] do
        member do
          post :move
          post :export
          get :render
        end
      end
    end
  end

  # Mount ActionCable
  mount ActionCable.server => '/cable'
end
