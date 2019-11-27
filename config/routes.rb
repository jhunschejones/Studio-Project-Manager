Rails.application.routes.draw do
  get 'comments/create'
  get 'comments/update'
  get 'comments/destroy'
  get 'projects/create'
  get 'projects/show'
  get 'projects/edit'
  get 'projects/update'
  get 'projects/index'
  get 'projects/delete'
  get 'projects/destroy'
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
