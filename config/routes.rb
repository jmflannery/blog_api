Rails.application.routes.draw do
  mount Toke::Engine => "/"

  resources :posts, only: [:index, :show]

  namespace :admin do
    resources :posts
  end
end
