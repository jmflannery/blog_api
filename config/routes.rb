Rails.application.routes.draw do
  mount Toke::Engine => "/"

  resources :posts
end
