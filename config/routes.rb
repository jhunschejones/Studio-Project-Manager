Rails.application.routes.draw do
  root to: "projects#index"

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :projects, except: [:delete] do
    resources :links, only: [:edit, :create, :update, :destroy]
  end
  resources :users, only: [:show]
end
