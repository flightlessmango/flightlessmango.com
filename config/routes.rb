Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :benches, :path => "benchmarks" do
    member do
      get 'recording'
      get 'video_line'
      get 'video_bar'
      get 'video_total'
      get 'delete_inputs'
      get 'delete_last_input'
      get 'delete_first_input'
      get 'totalbar'
      get 'total_cpu'
      get 'publish'
      get 'refresh'
    end
  end
  resources :benches_games do
    member do
      get 'frametime'
      get 'fps'
      get 'full_frametime'
      get 'full_fps'
      get 'bar'
      get 'gpu'
      get 'cpu'
    end
  end
  resources :apis_benches do
    member do
      get 'frametime'
      get 'fps'
      get 'full_frametime'
      get 'full_fps'
      get 'bar'
    end
  end
  resources :variations
  resources :games do
    collection do
      match 'search' => 'games#search', via: [:get, :post], as: :search
      match 'user_benchmarks' => 'games#user_benchmarks', via: [:get, :post], as: :user_benchmarks
    end
    resources :logs do
      member do
        get 'frametime'
        get 'fps'
        get 'bar'
        get 'cpu'
        get 'cpuavg'
        get 'update_blob_filename'
        get 'update_attachment_color'
        get 'update_attachment_name'
      end
    end
  end
  resources :logs
  resources :users do
    collection do
      get 'dashboard'
      get 'refresh_table'
    end
  end
  
  root 'benches#index'
  
end