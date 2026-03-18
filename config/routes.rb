Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  root "home#index"

  post 'set_city', to: 'home#set_city', as: :set_city

  resources :jobs do
    member do
      get :apply
      post :submit_application
    end
  end

  resources :shops
  resources :listings

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :users, only: [:index, :destroy]
    resources :shops, only: [:index, :destroy]
  end

  resource :myshop, only: [:show], controller: 'myshop' do
    get :configure, on: :collection
    patch :configure, on: :collection
    get :workers, on: :collection
      post :create_worker, on: :collection
    patch :update_worker, on: :collection
    get 'worker/:id/experience', to: 'myshop#worker_experience', on: :collection, as: :worker_experience
  end
  post 'myshop/subscribe', to: 'myshop#subscribe', as: :myshop_subscribe
  get 'myshop/offer/new', to: 'myshop#offer_new', as: :myshop_offer_new
  post 'myshop/offer', to: 'myshop#offer_create', as: :myshop_offer_create
  get 'shop_dashboard', to: 'shop_dashboard#index', as: :shop_dashboard
  resources :subscriptions, only: [:new, :create]
  namespace :webhooks do
    post 'stripe', to: 'stripe#create'
  end

  get 'newspaper', to: 'newspaper#show', as: :newspaper
  resources :farming, only: [:index, :show, :new, :create]

  # Myshop extras for shopowner exports
  get 'myshop/experience', to: 'myshop#experience', as: :myshop_experience
  get 'myshop/idcard', to: 'myshop#idcard', as: :myshop_idcard

  # placeholder resources for other modules
  resources :updates
  resources :farming
  resources :rents, only: [:index]
  resources :buy
  resources :services

  # Myservice routes for service providers
  resource :myservice, only: [:show], controller: 'myservice' do
    get :configure, on: :collection
    patch :configure, on: :collection
    post :configure, on: :collection
    get :business_card, on: :collection
    post :business_card, on: :collection
  end

  # Offers and Benefits page
  get 'offers', to: 'offers#index', as: :offers

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
