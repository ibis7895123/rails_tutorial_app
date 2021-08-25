Rails
  .application
  .routes
  .draw do
    # 静的ページ
    root 'static_pages#home'
    get '/help', to: 'static_pages#help'
    get '/about', to: 'static_pages#about'
    get '/contact', to: 'static_pages#contact'

    # ユーザー
    resources :users, except: %i[new create] do
      member do
        get :following
        get :followers
      end
    end

    get '/signup', to: 'users#new'
    post '/signup', to: 'users#create'

    get '/login', to: 'sessions#new'
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy'

    # アカウント有効化
    resources :account_activations, only: [:edit]

    # パスワードリセット
    resources :password_resets, only: %i[new create edit update]

    # 投稿
    resources :microposts, only: %i[create destroy]
  end
