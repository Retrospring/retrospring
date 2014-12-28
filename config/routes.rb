require 'sidekiq/web'
Rails.application.routes.draw do

  # Admin panel
  mount RailsAdmin::Engine => '/justask_admin', as: 'rails_admin'

  # Sidekiq
  constraints ->(req) { req.env["warden"].authenticate?(scope: :user) &&
                        req.env['warden'].user.admin? } do
    mount Sidekiq::Web, at: "/sidekiq"
  end

  # Moderation panel
  constraints ->(req) { req.env['warden'].authenticate?(scope: :user) &&
                       (req.env['warden'].user.admin? or req.env['warden'].user.moderator?) } do
    match '/moderation', to: 'moderation#index', via: :get, as: :moderation
  end

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

  # resources :services, only: [:index, :destroy]
  match '/settings/services', to: 'services#index', via: 'get', as: :services
  match '/settings/services/:id', to: 'services#destroy', via: 'delete', as: :service
  controller :services do
    scope "/auth", as: "auth" do
      get ':provider/callback' => :create
      get :failure
    end
  end

  namespace :ajax do
    match '/ask', to: 'question#create', via: :post, as: :ask
    match '/answer', to: 'inbox#destroy', via: :post, as: :answer
    match '/generate_question', to: 'inbox#create', via: :post, as: :generate_question
    match '/delete_inbox', to: 'inbox#remove', via: :post, as: :delete_inbox
    match '/delete_all_inbox', to: 'inbox#remove_all', via: :post, as: :delete_all_inbox
    match '/destroy_answer', to: 'answer#destroy', via: :post, as: :destroy_answer
    match '/create_friend', to: 'friend#create', via: :post, as: :create_friend
    match '/destroy_friend', to: 'friend#destroy', via: :post, as: :destroy_friend
    match '/create_smile', to: 'smile#create', via: :post, as: :create_smile
    match '/destroy_smile', to: 'smile#destroy', via: :post, as: :destroy_smile
    match '/create_comment', to: 'comment#create', via: :post, as: :create_comment
    match '/report', to: 'report#create', via: :post, as: :report
  end

  match '/public', to: 'public#index', via: :get, as: :public_timeline

  match '/notifications(/:type)', to: 'notifications#index', via: :get, as: :notifications, defaults: {type: 'all'}

  match '/inbox', to: 'inbox#show', via: 'get'
  
  match '/user/:username(/p/:page)', to: 'user#show', via: 'get', defaults: {page: 1}
  match '/@:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile, defaults: {page: 1}
  match '/@:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer
  match '/@:username/q/:id', to: 'question#show', via: 'get', as: :show_user_question
  match '/@:username/followers(/p/:page)', to: 'user#followers', via: 'get', as: :show_user_followers, defaults: {page: 1}
  match '/@:username/friends(/p/:page)', to: 'user#friends', via: 'get', as: :show_user_friends, defaults: {page: 1}
  match '/:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile_alt, defaults: {page: 1}
  match '/:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer_alt
  match '/:username/q/:id', to: 'question#show', via: 'get', as: :show_user_question_alt
  match '/:username/followers(/p/:page)', to: 'user#followers', via: 'get', as: :show_user_followers_alt, defaults: {page: 1}
  match '/:username/friends(/p/:page)', to: 'user#friends', via: 'get', as: :show_user_friends_alt, defaults: {page: 1}
  match '/:username/questions(/p/:page)', to: 'user#questions', via: 'get', as: :show_user_questions, defaults: {page: 1}
end
