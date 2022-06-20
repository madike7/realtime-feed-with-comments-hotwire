Rails.application.routes.draw do
  #get 'users/profile'
  devise_for :users
  
  resources :posts do
    resources :comments
    #member do
    #  patch :vote
    #end
    resource :likes, only: :show
  end

  resources :comments do
    resources :comments
  end

  resources :embeds, only: [:create], constraints: { id: /[^\/]+/ } do
    collection do
      get :patterns
    end
  end
  
  resources :mentions, only: [:index]

  #resources :youtube, only: :show
  get ':username', to: 'users#profile', as: 'user'  #user_path(user.username) gia na parw to profile enos user
  root 'posts#index'
end
