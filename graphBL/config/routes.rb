Rails.application.routes.draw do
  root 'layers#index'
  resources :layers do
    collection do
      get 'bike'
      get 'car'
      get 'point'
      post 'clusterer'
    end
  end
end
