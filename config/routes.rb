Rails.application.routes.draw do
  resources :posts do
    resources :comments
    #member do
    #  patch :vote
    #end
    resource :likes, only: :show
  end

  resources :embeds, only: [:create], constraints: { id: /[^\/]+/ } do
    collection do
      get :patterns
    end
  end
  
  resources :comments do
    resources :comments
  end
  
  resources :mentions, only: [:index]

  #resources :youtube, only: :show

  devise_for :users

  root 'posts#index'
end
