Rails.application.routes.draw do
  devise_for :members
  resources :members, only: [:index]
  root 'welcome#index'
end
