Rails.application.routes.draw do
  get "home/index"
  devise_for :users
  root 'home#index'


  resources :plans do
    member do
      get 'generate_reference_plan'
      get 'export_pdf'
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
