Rails.application.routes.draw do
  get 'rooms/index'
  get 'users/profile'
  get 'users/show'
  devise_for :users
  
  resources :posts do
    resources :comments
    resource :likes, only: :show
  end

  resources :comments

  resources :rooms do
    resources :messages, shallow: :true
    collection do
      post :search
    end
  end

  resources :embeds, only: [:create], constraints: { id: /[^\/]+/ } do
    collection do
      get :patterns
    end
  end
  
  resources :mentions, only: [:index]
  
  get ':username', to: 'users#profile', as: 'user_profile'  #user_path(user.username) gia na parw to profile enos user
  get 'user/:id', to: 'users#show', as: 'user'  # private chat room
  root 'posts#index'
end
