# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  devise_for :users
  ActiveAdmin.routes(self)

  get 'resources/sermon', to: 'resources#index', defaults: { format: :rss }

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
