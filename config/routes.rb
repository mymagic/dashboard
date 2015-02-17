Rails.application.routes.draw do
  devise_for :members

  resources :members, only: [:index, :show]
  resources :companies, only: [:index, :show]

  namespace :admin do
    resources :companies, only: [:index]
    resources :members, only: [:index]
  end

  root 'welcome#index'
end
