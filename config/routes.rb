Rails.application.routes.draw do
  mount Toker::Engine => "/"

  resources :posts do
    member do
      put :publish
    end
  end
end
