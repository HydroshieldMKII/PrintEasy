Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root to: "angular#index"
  namespace :api, constraints: { format: 'json' }  do
    resources :printer_user
    resources :printer
    resources :request
    resources :offer do
      member do
        put 'reject'
      end
    end
    resources :order_status
    resources :order
    resources :status
    resources :contest, except: [:new, :edit]
    resources :color
    resources :filament
    resources :submission
    resources :preset
  end

  match '*url', to: "angular#index", via: :get

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
