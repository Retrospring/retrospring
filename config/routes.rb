Rails.application.routes.draw do

  root 'static#index'

  match '/about', to: 'static#about', via: 'get'
end
