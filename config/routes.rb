Rails.application.routes.draw do
  root to: "projects#index"

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :projects, except: [:delete] do
    resources :events, only: [:edit, :create, :update, :destroy]
    resources :links, only: [:edit, :create, :update, :destroy]
    resources :comments, only: [:edit, :update, :destroy]
    resources :tracks, only: [:show, :edit, :create, :update, :destroy] do
      resources :track_versions, only: [:show, :edit, :create, :update, :destroy] do
        resources :links, only: [:create]
        resources :comments, only: [:new, :create]
      end
    end
    post '/users', to: 'users#add_to_project', as: :add_user
    delete '/users/:user_id', to: 'users#remove_from_project', as: :remove_user
  end
  resources :users, only: [:show]
end
