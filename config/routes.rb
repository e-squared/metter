Metter::Application.routes.draw do
  root "letters#new"

  get     "login"   => "session#new",      :as => "login"
  post    "login"   => "session#create"
  delete  "logout"  => "session#destroy",  :as => "logout"

  get   "profile" => "profile#edit",  :as => "profile"
  patch "profile" => "profile#update"

  get "about" => "static#about", :as => "about"

  concern :paginatable do
    get "page/:page", :action => "index", :on => :collection
  end

  concern :searchable do
    get "search", :action => "index", :on => :collection
  end

  get "dating/parse" => "letters#parse_dating", :as => "parse_dating"
  get "dating/help" => "letters#dating_help", :as => "dating_help"
  get "dating/adjust" => "letters#dating_adjust", :as => "dating_adjust"

  get "people/images" => "people#images", :as => "person_images"
  get "people/images/remove/:id" => "people#remove_image", :as => "remove_person_image"

  get  "contact" => "contactings#new",    :as => "contact"
  post "contact" => "contactings#create"

  resources :users
  resources :people, :concerns => [:paginatable, :searchable]
  resources :events, :concerns => [:paginatable, :searchable]
  resources :letters

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
