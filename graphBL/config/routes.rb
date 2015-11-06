Rails.application.routes.draw do
  if Rails.env.production?
    proxy_path = "app"
  elsif Rails.env.teste?
    proxy_path = "teste"
  end
  scope(:path => "/#{proxy_path}") do
    resources :user_suggestions
    root 'layers#index'
    resources :layers do
      collection do
        get 'bike'
        get 'car'
      end
    end

    resources :backups do
      collection do
        get 'restore'
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
        post 'change_edge_type'
      end
    end
  end
end
