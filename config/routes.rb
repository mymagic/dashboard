require 'sidekiq/web'
Rails.application.routes.draw do
  authenticate :member, lambda { |u| u.administrator? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  resources :communities, path: '', except: :index do
    get 'admin/dashboard'

    namespace :admin do
      resource :community, only: [:edit, :update]
      resources :networks
      resources :events, except: [:show]
      resources :companies
      resources :members do
        patch 'resend_invitation', on: :member
      end
      resources :companies, only: [:index, :show, :edit, :update] do
        resources :members, only: [:new, :create, :edit, :update]
      end
    end

    resources :networks, path: '', only: :show do
      namespace :admin do
        resources :events, except: [:show]
        resources :companies
        resources :members do
          patch 'resend_invitation', on: :member
        end
      end

      resource :calendar, only: :show do
        get 'feeds/:auth_token/:type',
          to: 'calendar_feeds#subscribe',
          as: 'feeds',
          constraints: { type: /events|availabilities/ }
        get 'feeds/:auth_token/reservations',
          to: 'calendar_feeds#reservations',
          as: 'reservation_feeds'
      end

      get 'availabilities/:year/:month/:day',
          to: 'availabilities#calendar',
          as: 'availability_calendar',
          constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }

      get 'events/:year/:month/:day',
          to: 'events#calendar',
          as: 'event_calendar',
          constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }

      resources :messages, only: :index do
        get 'search', on: :collection
      end

      resources :members, only: [:index, :show] do
        member do
          patch :follow
          delete :unfollow
        end

        resources :activities, only: :index
        resource :calendar, only: :show
        resources :messages
        resources :discussions, only: :index

        get 'availabilities/:year/:month/:day',
            to: 'availabilities#slots',
            as: 'availability_slots',
            constraints: { year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/ }

        resources :availabilities, except: [:show] do
          resource :slots,
                   path: 'slots/:hour/:minute',
                   constraints: { hour: /\d{1,2}/, minute: /\d{1,2}/ } do
                     collection do
                       post :reserve, to: 'slots#create'
                       delete :release, to: 'slots#destroy'
                     end
                   end
        end
      end

      get 'discussions/tagged/:tag_id',
          to: 'discussions#index',
          as: 'discussion_tag'

      resources :discussions do
        resources :comments, only: [:create, :update, :destroy]
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
      end
    end
  end

  scope ':community_id' do
    devise_for(
      :members,
      skip: [:registrations],
      controllers: {
        invitations: 'invitations',
        sessions: 'sessions'
      })
    as :member do
      delete '/leave', to: 'registrations#destroy', as: 'destroy_member_registration'
    end
    scope ':network_id' do
      as :member do
        scope 'account' do
          # settings & cancellation
          get '/', to: 'registrations#edit', as: 'edit_member_registration'
          put '/', to: 'registrations#update'
        end
      end
    end
  end

  root 'welcome#index'
  get 's3_callback/:model', to: 'uploads#s3_callback', as: "s3_callback"
  get '*missing' => redirect('/')
end
