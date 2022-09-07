Rails.application.routes.draw do
  devise_for :users, :controllers =>{registrations:'registrations'}
  get 'home/index'

  resources :tweets, :except =>[:edit] do
    resources :comments
  end
end
