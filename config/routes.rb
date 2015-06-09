Rails.application.routes.draw do
  scope ':community_id' do
    devise_for :members, controllers: {
      registrations: 'registrations',
      invitations: 'invitations',
      sessions: 'sessions'
    }
  end

  resources :communities, path: '', except: :index do
    resource  :calendar, only: :show
    get 'availabilities/:year/:month/:day',
      to: 'availabilities#calendar',
      as: 'availability_calendar',
      constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }

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
      resource  :calendar, only: :show
      resources :messages
      get 'availabilities/:year/:month/:day',
        to: 'availabilities#slots',
        as: 'availability_slots',
        constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }
      resources :availabilities, except: [:show] do
        resource :slots, path: 'slots/:hour/:minute',
          constraints: { hour: /\d{1,2}/, minute: /\d{1,2}/ } do
          collection do
            post :reserve, to: 'slots#create'
            delete :release, to: 'slots#destroy'
          end
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
