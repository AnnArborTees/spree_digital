Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :products do
      resources :digitals do
        collection do
          post :notify_orders
        end
      end
    end

    resources :orders do
      member do
        get :reset_digitals  
      end
    end
  end
  
  get '/digital/:secret', :to => 'digitals#show', :as => 'digital', :constraints => { :secret => /[a-zA-Z0-9]{30}/ }
end
