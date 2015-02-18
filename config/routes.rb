Rails.application.routes.draw do
  devise_for :members

  resources :members, only: [:index, :show]
  resources :companies, only: [:index, :show]

  namespace :admin do
    get :dashboard
    resources :companies
    resources :members, only: [:index]
  end

  root 'welcome#index'
end
