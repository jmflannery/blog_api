Rails.application.routes.draw do
  mount Toker::Engine => "/"

  resources :posts
end
