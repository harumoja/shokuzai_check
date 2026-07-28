Rails.application.routes.draw do
  root "homes#index"

  resources :babyfoods, only: %i[index show]
end