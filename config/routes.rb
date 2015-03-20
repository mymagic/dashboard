Rails.application.routes.draw do
  devise_for :members, controllers: {
    registrations: 'registrations',
    invitations: 'invitations'
  }

  resources :members, only: [:index, :show]
  resources :companies, only: [:index, :show] do
    resources :members, only: [:new, :create, :edit, :update]
  end
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
      patch 'resend_invitation', on: :member
    end
    resources :positions
  end

  root 'welcome#index'
end
