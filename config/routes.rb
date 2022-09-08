Rails.application.routes.draw do
  root to: "tweets#index"
  devise_for :users, :controllers =>{registrations:'registrations'}
  get 'home/index'

  resources :tweets, :except =>[:edit] do
    resources :comments
    member do
      post :retweet
    end
  end

  post 'like/:id',to: "tweets#like",as: "like_tweet"

  resources :profiles do
    resources :friendships,only: [:create,:destroy]
  end
end
