Rails.application.routes.draw do
  root to: "projects#index"

  devise_for :users

  resources :projects, only: [:index, :show]
  resources :users, only: [:show]
end
