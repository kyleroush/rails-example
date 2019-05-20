Rails.application.routes.draw do
  resources :orders, only: [:create] do
    post 'checkout', on: :member
  end
end
