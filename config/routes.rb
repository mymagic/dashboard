Rails.application.routes.draw do
  scope ':community_id' do
    devise_for :members, controllers: {
      registrations: 'registrations',
      invitations: 'invitations',
      sessions: 'sessions'
    }
  end

  resources :communities, path: '', except: :index do
    get 'discussions/tagged/:tag_id', to: 'discussions#index', as: 'discussion_tag'
    get 'discussions/tags', to: 'discussions#tags', as: 'discussion_tags'
    resource  :calendar, only: :show

    resources :messages, only: :index do
      get 'search', on: :collection
    end
    get 'availabilities/:year/:month/:day',
      to: 'availabilities#index',
      as: 'availability_slots',
      constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }
    resources :members, only: [:index, :show] do
      resources :messages
      get 'availabilities/:year/:month/:day',
        to: 'availabilities#index',
        as: 'availability_slots',
        constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }
      resources :availabilities do
        resource :slots, path: 'slots/:hour/:minute',
          constraints: { hour: /\d{1,2}/, minute: /\d{1,2}/ } do
          post :reserve, to: 'slots#create', on: :collection
        end
      end
    end
    resources :discussions, except: [:edit, :update] do
      resources :comments, only: [:create, :destroy]
      member do
        patch :follow
        delete :unfollow
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
