Rails.application.routes.draw do
  resources :sleep_records
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Custom route for following action
  post "users/:id/following" => "users#following", as: :user_following
  post "users/:id/clock_in" => "users#clock_in", as: :user_clock_in
  post "users/:id/clock_out" => "users#clock_out", as: :user_clock_out
  get "users/:id/sleep_records" => "users#sleep_records", as: :user_sleep_records
  post "users/:id/follow" => "users#follow", as: :user_follow
  post "users/:id/unfollow" => "users#unfollow", as: :user_unfollow

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
