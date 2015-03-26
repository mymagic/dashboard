Rails.application.routes.draw do
  devise_for :members, skip: [:sessions], controllers: {
    registrations: 'registrations',
    invitations: 'invitations'
  }

  resources :communities, path: '', except: :index do
    devise_for :members, only: [:sessions], controllers: {
      sessions: 'sessions'
    }

    resources :members, only: [:index, :show]
    resources :companies, only: [:index, :show]
    resources :companies_members_positions, only: [:create]
    resources :office_hours, only: [:index, :create, :destroy] do
      patch 'book', on: :member
      delete 'cancel', on: :member
    end

    get 'admin/dashboard'

    namespace :admin do
      resources :companies
      resources :office_hours
      resources :members do
        patch 'resend_invitation', on: :member
      end
      resources :positions
    end
  end

  root 'welcome#index'
  get '*missing' => redirect('/')
end
