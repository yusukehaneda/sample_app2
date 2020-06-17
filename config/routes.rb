Rails.application.routes.draw do
  #root 'application#hello'
  root 'static_pages#home'
    #root_path -> '/'
    #root_url  -> 'https://www.example.com/'
    #get  'static_pages/home'
    # =>  StaticPages#home

  get  '/help',    to: 'static_pages#help'
    #get  'static_pages/help'
    # => StaticPages#help
    #help_path -> '/help'
    #help_url  -> 'https://www.example.com/help'

  get  '/about',   to: 'static_pages#about'
    #get  'static_pages/about'
    # => StaticPages#about

  get  '/contact', to: 'static_pages#contact'
    #get  'static_pages/contact'
    # => StaticPages#contact
  get '/signup', to: 'users#new'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users do
    member do
      get :following, :followers
     # GET /users/1/following
     # GET /users/1/followers
    end
  end


  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]

end


