Rails.application.routes.draw do
  resources :sleep_records
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Custom route for following action
  post "users/:id/following" => "users#following", as: :user_following
  
  #authentication needed
  post "login" => "users#login", as: :login
  get "self/profile" => "users#profile", as: :profile
  post "self/clock_in" => "users#clock_in", as: :user_clock_in
  post "self/clock_out" => "users#clock_out", as: :user_clock_out
  post "self/follow" => "users#follow", as: :user_follow
  post "self/unfollow" => "users#unfollow", as: :user_unfollow
  get "self/sleep_records" => "users#sleep_records", as: :user_sleep_records

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
