Rails.application.routes.draw do

  devise_for :users
  root 'static#index'

  match '/about', to: 'static#about', via: 'get'
end
