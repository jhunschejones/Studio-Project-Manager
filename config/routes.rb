Rails.application.routes.draw do
  root to: "projects#index"

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :projects, only: [:index, :show, :edit, :update]
  resources :users, only: [:show]
end
