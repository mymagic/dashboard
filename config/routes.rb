Rails.application.routes.draw do
  devise_for :members
  resources :members, only: [:index]

  resources :companies, only: [:index, :show]

  root 'welcome#index'
end
