Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]

  root "dashboard#show"

  resources :properties, only: %i[index show]
  resources :tenants, only: %i[index new create edit update]

  resources :leases, only: %i[show new create destroy] do
    patch :end, on: :member, action: :end_early
    resources :payments, only: :create
  end

  resources :payments, only: %i[index show edit update destroy] do
    patch :void, on: :member
  end

  get "arrears", to: "arrears#index"
  get "renewals", to: "renewals#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
