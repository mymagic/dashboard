Rails.application.routes.draw do
  concern :calendar_availabilities do
    get 'availabilities/:year/:month/:day',
      to: 'availabilities#index',
      as: 'availability_slots',
      constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }
  end
  scope ':community_id' do
    devise_for :members, controllers: {
      registrations: 'registrations',
      invitations: 'invitations',
      sessions: 'sessions'
    }
  end

  resources :communities, path: '', except: :index do
    concern :calendar_availabilities
    resource  :calendar, only: :show

    resources :messages, only: :index do
      get 'search', on: :collection
    end
    resources :messages, only: :index do
      get 'search', on: :collection
    end
    resources :members, only: [:index, :show] do
      member do
        patch :follow
        delete :unfollow
      end
      resources :messages
      concern :calendar_availabilities
      resources :availabilities do
        resource :slots, path: 'slots/:hour/:minute',
          constraints: { hour: /\d{1,2}/, minute: /\d{1,2}/ } do
          post :reserve, to: 'slots#create', on: :collection
        end
      end
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

    get 'admin/dashboard'

    namespace :admin do
      resource :community, only: [:edit, :update]
      resources :events, except: [:show]
      resources :companies
      resources :companies_members_positions
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
