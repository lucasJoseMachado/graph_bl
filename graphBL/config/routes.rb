Rails.application.routes.draw do
  root 'layers#index'
  resources :layers do
    collection do
      get 'bike'
      get 'car'
      get 'point'
    end
  end

  resources :proposer do
    collection do
      post 'clusterer'
      post 'path'
      post 'calculate_score'
      post 'get_pairs'
      post 'propose'
      post 'add_bike_lane'
    end
  end
end
