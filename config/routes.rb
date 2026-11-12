# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  devise_for :users, skip: :sessions
  devise_scope :user do
    get 'admin/login', to: 'users/sessions#new', as: :new_user_session
    post 'admin/login', to: 'users/sessions#create', as: :user_session
    delete 'admin/logout', to: 'users/sessions#destroy', as: :destroy_user_session
  end
  ActiveAdmin.routes(self)

  get 'resources/sermon', to: 'resources#index', defaults: { format: :rss }

  # Preserve links emitted by the retired public sermon UI. These nested
  # paths predate the current REST routes but still carry Google visibility.
  get 'resources/sermon/authors/:id', to: 'resources/authors#show'
  get 'resources/sermon/scriptures/:id', to: 'resources/scriptures#show'
  get 'resources/sermon/series/:id', to: 'resources/series#show'
  get 'resources/sermon/topics/:id', to: 'resources/topics#show'
  get 'resources/sermon/:id', to: 'resources#show'

  # Old sermon pages embedded relative BibleGateway links at /passage.
  get 'passage', to: 'resources#passage'

  resources :resources, only: %i[index show] do
    collection do
      scope module: :resources do
        resources :authors, only: %i[index show]
        resources :scriptures, only: %i[index show]
        resources :series, only: %i[index show]
        resources :topics, only: %i[index show]
      end
    end
  end

  public_sermon_library_redirect = redirect('https://www.ev.church/sermons', status: :moved_permanently)

  get '/', to: public_sermon_library_redirect
  get 'home', to: public_sermon_library_redirect
  get 'permissions', to: public_sermon_library_redirect, as: :permissions
  get 'privacy', to: public_sermon_library_redirect, as: :privacy
  get 'terms', to: public_sermon_library_redirect, as: :terms
end
