Rails.application.routes.draw do
  devise_for :members

  resources :members, only: [:index, :show]
  resources :companies, only: [:index, :show]
  resources :companies_members_positions, only: [:create]
  resources :office_hours, only: [:index, :create, :destroy] do
    patch 'book', on: :member
    delete 'cancel', on: :member
  end

  namespace :admin do
    get :dashboard
    resources :companies
    resources :office_hours
    resources :members do
      patch 'confirm', on: :member
    end
    resources :positions
  end

  root 'welcome#index'
end
