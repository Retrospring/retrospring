Rails.application.routes.draw do

  root 'static#index'

  match '/about', to: 'static#about', via: 'get'

  # Devise routes
  devise_for :users, path: 'user', skip: [:sessions, :registrations]
  as :user do
    # :sessions
    get 'sign_in' => 'devise/sessions#new', as: :new_user_session
    post 'sign_in' => 'devise/sessions#create', as: :user_session
    delete 'sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
    # :registrations
    get 'settings/delete_account' => 'devise/registrations#cancel', as: :cancel_user_registration
    post '/user/create' => 'devise/registrations#create', as: :user_registration
    get '/sign_up' => 'devise/registrations#new', as: :new_user_registration
    get '/settings/account' => 'devise/registrations#edit', as: :edit_user_registration
    patch '/settings/account' => 'devise/registrations#update', as: :update_user_registration
    put '/settings/account' => 'devise/registrations#update'
    delete '/settings/account' => 'devise/registrations#destroy'
  end

  match '/settings/profile', to: 'user#edit', via: 'get', as: :edit_user_profile
  match '/settings/profile', to: 'user#update', via: 'patch', as: :update_user_profile
  
  namespace :ajax do
    match '/ask', to: 'question#create', via: :post, as: :ask
    match '/answer', to: 'inbox#destroy', via: :post, as: :answer
    match '/delete_inbox', to: 'inbox#remove', via: :post, as: :delete_inbox
    match '/destroy_answer', to: 'answer#destroy', via: :post, as: :destroy_answer
    match '/create_friend', to: 'friend#create', via: :post, as: :create_friend
    match '/destroy_friend', to: 'friend#destroy', via: :post, as: :destroy_friend
    match '/create_smile', to: 'smile#create', via: :post, as: :create_smile
    match '/destroy_smile', to: 'smile#destroy', via: :post, as: :destroy_smile
  end

  match '/inbox', to: 'inbox#show', via: 'get'
  
  match '/user/:username(/p/:page)', to: 'user#show', via: 'get', defaults: {page: 1}
  match '/@:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile, defaults: {page: 1}
  match '/@:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer
  match '/:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile_alt, defaults: {page: 1}
  match '/:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer_alt
end
