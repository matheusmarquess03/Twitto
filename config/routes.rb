Rails.application.routes.draw do
  root to: "tweets#index"
  devise_for :users, :controllers =>{registrations:'registrations'}
  get 'home/index'

  mount ActionCable.server => '/cable'

  resources :tweets, :except =>[:edit] do
    resources :comments
    member do
      post :retweet
    end
  end

  post 'like/:id', to: "tweets#like", as: "like_tweet"
  get  'like/:id', to: "tweets#like_button", as: "like_button"

  resources :notifications do
    collection do
      post :mark_as_read
    end
  end

  resources :profiles do
    resources :friendships,only: [:create,:destroy]
    member do
      get :friendlist
    end
  end
end
