Rails.application.routes.draw do
  root to: "projects#index"

  # providing custom behavior for devise controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :projects, except: [:delete]
  delete '/projects/:id/files/:file_id', to: 'projects#destroy_file', as: 'destroy_file_path'
  resources :users, only: [:show]
end
