Rails.application.routes.draw do
  root to: "projects#index"

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :projects, except: [:delete] do
    resources :links, only: [:edit, :create, :update, :destroy]
    post '/users', to: 'users#add_to_project', as: :add_user
    delete '/users/:user_id', to: 'users#remove_from_project', as: :remove_user
  end
  resources :users, only: [:show]
end
