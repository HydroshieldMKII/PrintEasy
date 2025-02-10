Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    post 'users/sign_up', to: 'users/registrations#create'
  end

  root to: "angular#index"
  namespace :api, constraints: { format: 'json' }  do
    resources :request
    resources :offer
  end

  match '*url', to: "angular#index", via: :get

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
