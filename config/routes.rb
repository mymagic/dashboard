Rails.application.routes.draw do
  scope ':community_id' do
    devise_for :members, controllers: {
      registrations: 'registrations',
      invitations: 'invitations',
      sessions: 'sessions'
    }
  end

  resources :communities, path: '', except: :index do
    resources :members, only: [:index, :show]
    resources :companies, only: [:index, :show, :edit, :update] do
      resources :members, only: [:new, :create, :edit, :update]
      resources :companies_members_positions, only: [:index, :create]
    end
    resources :office_hours, only: [:index, :create, :destroy] do
      patch 'book', on: :member
      delete 'cancel', on: :member
    end

    get 'admin/dashboard'

    namespace :admin do
      resources :companies
      resources :companies_members_positions
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
