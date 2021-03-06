MenuMaster::Application.routes.draw do
  root 'static_pages#home'
  resources :users do
    member do
      get :following, :followers
    end
    member do
      resources :microposts, only: [] do
        collection do
          get :activity
        end
      end
    end
    resources :meals
  end
  resources :sessions,      only: [:new, :create, :destroy]
  resources :microposts,    only: [:create, :destroy, :index] 
  resources :relationships, only: [:create, :destroy]
  resources :foods
  resources :food_imports, only: [:new, :create]
  resources :recipes do
    resources :ingredients
    collection do
      get :browse
    end
  end
  
  get "signup/"  => 'users#new'

  scope controller: :static_pages do
    get "help/"    => :help
    get "about/"   => :about
    get "contact/" => :contact
    get "home_recipe_nav" => :recipe_nav
  end

  get "signin/"  => 'sessions#new'
  delete "signout/" => 'sessions#destroy'

  get "newsfeed/" => 'microposts#index'
  
  get 'users/:id/microposts' => 'microposts#user', as: :user_microposts
  get 'users/:id/recipes'    => 'recipes#user',    as: :user_recipes

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
