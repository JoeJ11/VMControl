VMControl::Application.routes.draw do
  resources :user_groups do
    collection do
      get 'select'
    end
    member do
      get 'join'
    end
  end

  resources :experiments do
    member do
      get 'start'
      get 'stop'
    end
  end

  resources :courses

  resources :cluster_configurations do
    member do
      get 'new_machine'
      get 'instantiate'
    end
  end

  resources :cluster_templates

  resources :images

  resources :students

  resources :dispatches do
    collection do
      get 'list'
      get 'service'
      get 'file'
      # post 'assign'
    end
    member do
      get 'progress'
      get 'start'
      get 'stop'
    end
  end

  # namespace :api do
  #   resources :cluster_configurations do
  #     collection do
  #       get 'testpost'
  #     end
  #   end
  # end
  # get 'dispatches/list'
  # get 'dispatches/new'
  # get 'dispatches/stop'
  # get 'dispatches/progress'
  # get 'dispatches/service'
  # post 'dispatches' => 'dispatches#create'
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

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
