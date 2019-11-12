Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  #match ':id', as: :benchshow, via: :get, controller: :benches, action: :show
  resources :benches, :path => "benchmarks" do
    member do
      get 'recording'
      get 'video_line'
      get 'video_bar'
      get 'video_total'
      get 'delete_inputs'
      get 'totalbar'
      get 'publish'
    end
  end
  resources :benches_games
  resources :apis_benches
  resources :variations
  resources :games do
    collection do
      match 'search' => 'games#search', via: [:get, :post], as: :search
      match 'user_benchmarks' => 'games#user_benchmarks', via: [:get, :post], as: :user_benchmarks
    end
    resources :logs do
      member do
        get 'update_blob_filename'
        get 'update_attachment_color'
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
  
  get '/benches_games/:id/frametime',      to: 'benches_games#frametime',       as: 'benches_game_frametime'
  get '/benches_games/:id/fps',            to: 'benches_games#fps',             as: 'benches_game_fps'
  get '/benches_games/:id/full_frametime', to: 'benches_games#full_frametime',  as: 'benches_game_full_frametime'
  get '/benches_games/:id/full_fps',       to: 'benches_games#full_fps',        as: 'benches_game_full_fps'  
  get '/benches_games/:id/bar',            to: 'benches_games#bar',             as: 'benches_game_bar'
  get '/benches_games/:id/gpu',            to: 'benches_games#gpu',             as: 'benches_game_gpu'
  get '/benches_games/:id/cpu',            to: 'benches_games#cpu',             as: 'benches_game_cpu'
   
  get '/apis_benches/:id/frametime',       to: 'apis_benches#frametime',        as: 'apis_bench_frametime'
  get '/apis_benches/:id/fps',             to: 'apis_benches#fps',              as: 'apis_bench_fps'
  get '/apis_benches/:id/full_frametime',  to: 'apis_benches#full_frametime',   as: 'apis_bench_full_frametime'
  get '/apis_benches/:id/full_fps',        to: 'apis_benches#full_fps',         as: 'apis_bench_full_fps'  
  get '/apis_benches/:id/bar',             to: 'apis_benches#bar',              as: 'apis_bench_bar'
  
  get '/logs/:id/frametime',               to: 'logs#frametime',                as: 'log_frametime'
  get '/logs/:id/fps',                     to: 'logs#fps',                      as: 'log_fps'
  get '/logs/:id/bar',                     to: 'logs#bar',                      as: 'log_bar'
  
  # get '/benchmarks/:id/recording',         to: 'benches#recording',             as: 'benches_recording'
  # get '/benchmarks/:id/video_line',        to: 'benches#video_line',            as: 'benches_video_line'
  # get '/benchmarks/:id/video_bar',         to: 'benches#video_bar',             as: 'benches_video_bar'
  # get '/benchmarks/:id/video_total',       to: 'benches#video_total',           as: 'benches_video_total'
  # get '/benchmarks/:id/delete_inputs',     to: 'benches#delete_inputs',         as: 'benches_delete_inputs'
  # get '/benchmarks/:id/totalbar',          to: 'benches#totalbar',              as: 'benches_totalbar'
  
  get '/games_logs',                     to: 'games#games_logs',                      as: 'games_logs'
  
  # get '/user_submissions',                 to: 'games#user_submissions',        as: 'user_submissions'
  # get '/user_submissions/:id/',            to: 'games#game',                    as: 'games_user_benchmarks'
  # get '/new_benchmark',                    to: 'logs#new_benchmark',            as: 'new_benchmark'
  # get '/user_submissions/:id/benchmark/:log_id/edit', to: 'logs#edit_benchmark',               as: 'edit_benchmark'
  # get '/user_submissions/:id/benchmark/:log_id',         to: 'logs#show',                     as: 'games_user_benchmark_show'
  # 
  # get '/user_submissions/:id/benchmark/:log_id/update_blob_filename', to: 'logs#update_blob_filename',               as: 'update_blob_filename'
  # get '/user_submissions/:id/benchmark/:log_id/update_attachment_color', to: 'logs#update_attachment_color',               as: 'update_attachment_color'
  
  root 'benches#index'
  
end