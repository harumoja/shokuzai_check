Rails.application.routes.draw do
  root "homes#index"

  resources :babyfoods, only: %i[index show]

  get "/terms", to: "static_pages#terms", as: :terms
  get "/privacy", to: "static_pages#privacy", as: :privacy
end
