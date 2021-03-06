Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  devise_for :users
  ActiveAdmin.routes(self)

  get 'resources/(:resource_type)', to: 'resources#index', constraints: ResourceTypeConstraint.new, as: :resources
  resources :resources, only: %i[index show] do
    collection do
      scope '/(:resource_type)', module: :resources, constraints: ResourceTypeConstraint.new do
        resources :authors, only: %i[index show]
        resources :scriptures, only: %i[index show]
        resources :series, only: %i[index show]
        resources :topics, only: %i[index show]
      end
    end
  end

  get 'permissions' => 'high_voltage/pages#show', id: 'permissions'
  get 'privacy' => 'high_voltage/pages#show', id: 'privacy'
  get 'terms' => 'high_voltage/pages#show', id: 'terms'
end
