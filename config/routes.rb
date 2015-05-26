Rails.application.routes.draw do
  scope ':community_id' do
    devise_for :members, controllers: {
      registrations: 'registrations',
      invitations: 'invitations',
      sessions: 'sessions'
    }
  end

  resources :communities, path: '', except: :index do
    resources :messages, only: :index do
      get 'search', on: :collection
    end

    resources :members, only: [:index, :show] do
      resources :messages
    end

    get 'discussions/tagged/:tag_id', to: 'discussions#index', as: 'discussion_tag'
    resources :discussions, except: [:edit, :update] do
      resources :comments, only: [:create, :destroy]
      member do
        patch :follow
        delete :unfollow
      end
    end

    resources :events, only: [:show] do
      member do
        patch :rsvp
      end
    end

    resources :companies, only: [:index, :show, :edit, :update] do
      resources :members, only: [:new, :create, :edit, :update]
      resources :companies_members_positions do
        member do
          patch :approve
          delete :reject
        end
      end
    end

    resources :office_hours, only: [:index, :create, :destroy] do
      patch 'book', on: :member
      delete 'cancel', on: :member
    end

    get 'admin/dashboard'

    namespace :admin do
      resources :events, except: [:show]
      resources :companies
      resources :companies_members_positions
      resources :office_hours
      resources :members do
        patch 'resend_invitation', on: :member
      end
      resources :positions
      resources :companies_members_positions do
        member do
          patch :approve
          delete :reject
        end
      end
    end
  end

  root 'welcome#index'
  get '*missing' => redirect('/')
end
