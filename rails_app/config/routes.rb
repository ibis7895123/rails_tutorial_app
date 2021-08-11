Rails
  .application
  .routes
  .draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    root 'static_pages#home'
    get '/help', to: 'static_pages#help'
    get '/about', to: 'static_pages#about'
    get '/contact', to: 'static_pages#contact'

    resources :users, except: %i[new create]
    get '/signup', to: 'users#new'
    post '/signup', to: 'users#create'
  end
