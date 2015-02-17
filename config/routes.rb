Rails.application.routes.draw do
  devise_for :members
  resources :members, only: [:index, :show]

  resources :companies, only: [:index, :show]

  root 'welcome#index'
end
