Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :clients, only: :create
  resources :tables, only: %i(index create) do
    resources :players, only: %i(create) do
      post :move, on: :member
    end
  end
end
