require 'sidekiq/web'
Rails.application.routes.draw do

  # Admin panel
  mount RailsAdmin::Engine => '/justask_admin', as: 'rails_admin'

  # Sidekiq
  constraints ->(req) { req.env["warden"].authenticate?(scope: :user) &&
                        req.env['warden'].user.admin? } do
    mount Sidekiq::Web, at: "/sidekiq"
    mount PgHero::Engine, at: "/pghero", as: 'pghero'
  end

  # Moderation panel
  constraints ->(req) { req.env['warden'].authenticate?(scope: :user) &&
                       (req.env['warden'].user.mod?) } do
    match '/moderation/priority(/:user_id)', to: 'moderation#priority', via: :get, as: :moderation_priority
    match '/moderation/ip/:user_id', to: 'moderation#ip', via: :get, as: :moderation_ip
    match '/moderation(/:type)', to: 'moderation#index', via: :get, as: :moderation, defaults: {type: 'all'}
    namespace :ajax do
      match '/mod/destroy_report', to: 'moderation#destroy_report', via: :post, as: :mod_destroy_report
      match '/mod/create_comment', to: 'moderation#create_comment', via: :post, as: :mod_create_comment
      match '/mod/destroy_comment', to: 'moderation#destroy_comment', via: :post, as: :mod_destroy_comment
      match '/mod/create_vote', to: 'moderation#vote', via: :post, as: :mod_create_vote
      match '/mod/destroy_vote', to: 'moderation#destroy_vote', via: :post, as: :mod_destroy_vote
      match '/mod/privilege', to: 'moderation#privilege', via: :post, as: :mod_privilege
      match '/mod/ban', to: 'moderation#ban', via: :post, as: :mod_ban
    end
  end

  root 'static#index'

  match '/about', to: 'static#about', via: 'get'
  match '/help/faq', to: 'static#faq', via: 'get', as: :help_faq
  match '/privacy', to: 'static#privacy_policy', via: 'get', as: :privacy_policy
  match '/terms', to: 'static#terms', via: 'get', as: :terms

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
    delete '/settings/account' => 'user/registrations#destroy'
  end

  match '/settings/profile', to: 'user#edit', via: 'get', as: :edit_user_profile
  match '/settings/profile', to: 'user#update', via: 'patch', as: :update_user_profile

  match '/settings/theme', to: 'user#edit_theme', via: 'get', as: :edit_user_theme
  match '/settings/theme', to: 'user#update_theme', via: 'patch', as: :update_user_theme
  match '/settings/theme/preview.css', to: 'user#preview_theme', via: 'post', as: :preview_user_theme
  match '/settings/theme/delete', to: 'user#delete_theme', via: 'delete', as: :delete_user_theme

  # resources :services, only: [:index, :destroy]
  match '/settings/services', to: 'services#index', via: 'get', as: :services
  match '/settings/services/:id', to: 'services#destroy', via: 'delete', as: :service
  controller :services do
    scope "/auth", as: "auth" do
      get ':provider/callback' => :create
      get :failure
    end
  end

  match '/settings/privacy', to: 'user#edit_privacy', via: :get, as: :edit_user_privacy
  match '/settings/privacy', to: 'user#update_privacy', via: :patch, as: :update_user_privacy

  match '/settings/data', to: 'user#data', via: :get, as: :user_data
  match '/settings/export', to: 'user#export', via: :get, as: :user_export
  match '/settings/export', to: 'user#begin_export', via: :post, as: :begin_user_export

  namespace :ajax do
    match '/ask', to: 'question#create', via: :post, as: :ask
    match '/destroy_question', to: 'question#destroy', via: :post, as: :destroy_question
    match '/generate_question', to: 'inbox#create', via: :post, as: :generate_question
    match '/delete_inbox', to: 'inbox#remove', via: :post, as: :delete_inbox
    match '/delete_all_inbox', to: 'inbox#remove_all', via: :post, as: :delete_all_inbox
    match '/delete_all_inbox/:author', to: 'inbox#remove_all_author', via: :post, as: :delete_all_author
    match '/answer', to: 'answer#create', via: :post, as: :answer
    match '/destroy_answer', to: 'answer#destroy', via: :post, as: :destroy_answer
    match '/create_friend', to: 'friend#create', via: :post, as: :create_friend
    match '/destroy_friend', to: 'friend#destroy', via: :post, as: :destroy_friend
    match '/create_smile', to: 'smile#create', via: :post, as: :create_smile
    match '/destroy_smile', to: 'smile#destroy', via: :post, as: :destroy_smile
    match '/create_comment_smile', to: 'smile#create_comment', via: :post, as: :create_comment_smile
    match '/destroy_comment_smile', to: 'smile#destroy_comment', via: :post, as: :destroy_comment_smile
    match '/create_comment', to: 'comment#create', via: :post, as: :create_comment
    match '/destroy_comment', to: 'comment#destroy', via: :post, as: :destroy_comment
    match '/report', to: 'report#create', via: :post, as: :report
    match '/create_group', to: 'group#create', via: :post, as: :create_group
    match '/destroy_group', to: 'group#destroy', via: :post, as: :destroy_group
    match '/group_membership', to: 'group#membership', via: :post, as: :group_membership
    match '/preview', to: "question#preview", via: :post, as: :preview
    match '/subscribe', to: 'subscription#subscribe', via: :post, as: :subscribe_answer
    match '/unsubscribe', to: 'subscription#unsubscribe', via: :post, as: :unsubscribe_answer
  end

  match '/discover', to: 'discover#index', via: :get, as: :discover
  match '/public', to: 'public#index', via: :get, as: :public_timeline
  match '/group/:group_name', to: 'group#index', via: :get, as: :group_timeline

  match '/notifications(/:type)', to: 'notifications#index', via: :get, as: :notifications, defaults: {type: 'new'}

  match '/inbox', to: 'inbox#show', via: 'get'
  match '/inbox/:author', to: 'inbox#show', via: 'get'

  match '/user/:username(/p/:page)', to: 'user#show', via: 'get', defaults: {page: 1}
  match '/@:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile_alt, defaults: {page: 1}
  match '/@:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer_alt
  match '/@:username/q/:id', to: 'question#show', via: 'get', as: :show_user_question_alt
  match '/@:username/followers(/p/:page)', to: 'user#followers', via: 'get', as: :show_user_followers_alt, defaults: {page: 1}
  match '/@:username/friends(/p/:page)', to: 'user#friends', via: 'get', as: :show_user_friends_alt, defaults: {page: 1}
  match '/:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile, defaults: {page: 1}
  match '/:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer
  match '/:username/q/:id', to: 'question#show', via: 'get', as: :show_user_question
  match '/:username/followers(/p/:page)', to: 'user#followers', via: 'get', as: :show_user_followers, defaults: {page: 1}
  match '/:username/friends(/p/:page)', to: 'user#friends', via: 'get', as: :show_user_friends, defaults: {page: 1}
  match '/:username/groups(/p/:page)', to: 'user#groups', via: 'get', as: :show_user_groups, defaults: {page: 1}
  match '/:username/questions(/p/:page)', to: 'user#questions', via: 'get', as: :show_user_questions, defaults: {page: 1}
end
