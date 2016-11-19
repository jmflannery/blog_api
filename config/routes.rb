Rails.application.routes.draw do
  resources :posts, only: [:index, :show]

  namespace :admin do
    resources :posts
  end
end
