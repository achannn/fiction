Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  devise_for :users

  root "stories#index"
  resources :stories, param: :code, path: 's' do
    resources :chapters, param: :number, path: 'c', except: :index
    resources :blobs, path: 'b', except: [:index, :show]
  end
  match '/write', to: 'dashboard#index', via: 'get'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
