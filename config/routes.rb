require 'sidekiq/web'
Rails.application.routes.draw do
  start = Time.now

  # Routes only accessible by admins (admin panels, sidekiq, pghero)
  authenticate :user, ->(user) { user.has_role?(:administrator) } do
    # Admin panel
    mount RailsAdmin::Engine => "/justask_admin", as: "rails_admin"

    mount Sidekiq::Web, at: "/sidekiq"
    mount PgHero::Engine, at: "/pghero", as: "pghero"

    match "/admin/announcements", to: "announcement#index", via: :get, as: :announcement_index
    match "/admin/announcements", to: "announcement#create", via: :post, as: :announcement_create
    match "/admin/announcements/new", to: "announcement#new", via: :get, as: :announcement_new
    match "/admin/announcements/:id/edit", to: "announcement#edit", via: :get, as: :announcement_edit
    match "/admin/announcements/:id", to: "announcement#update", via: :patch, as: :announcement_update
    match "/admin/announcements/:id", to: "announcement#destroy", via: :delete, as: :announcement_destroy
  end

  # Routes only accessible by moderators (moderation panel)
  authenticate :user, ->(user) { user.mod? } do
    match '/moderation/unmask', to: 'moderation#toggle_unmask', via: :post, as: :moderation_toggle_unmask
    match '/moderation(/:type)', to: 'moderation#index', via: :get, as: :moderation, defaults: {type: 'all'}
    match '/moderation/inbox/:user', to: 'moderation/inbox#index', via: :get, as: :mod_inbox_index
    namespace :ajax do
      match '/mod/destroy_report', to: 'moderation#destroy_report', via: :post, as: :mod_destroy_report
      match '/mod/privilege', to: 'moderation#privilege', via: :post, as: :mod_privilege
      match '/mod/ban', to: 'moderation#ban', via: :post, as: :mod_ban
    end
  end

  unauthenticated :user do
    root to: 'about#index'
  end

  authenticate :user do
    root to: 'timeline#index', as: :timeline
  end

  match '/about', to: 'about#about', via: 'get'
  match '/privacy', to: 'about#privacy_policy', via: 'get', as: :privacy_policy
  match '/terms', to: 'about#terms', via: 'get', as: :terms
  match '/linkfilter', to: 'link_filter#index', via: 'get', as: :linkfilter
  match '/manifest.json', to: 'manifests#show', via: 'get', as: :webapp_manifest

  # Devise routes
  devise_for :users, path: 'user', skip: [:sessions, :registrations]
  as :user do
    # :sessions
    get 'sign_in' => 'user/sessions#new', as: :new_user_session
    post 'sign_in' => 'user/sessions#create', as: :user_session
    delete 'sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
    # :registrations
    get 'settings/delete_account' => 'devise/registrations#cancel', as: :cancel_user_registration
    post '/user/create' => 'user/registrations#create', as: :user_registration
    get '/sign_up' => 'devise/registrations#new', as: :new_user_registration
    get '/settings/account' => 'devise/registrations#edit', as: :edit_user_registration
    patch '/settings/account' => 'devise/registrations#update', as: :update_user_registration
    put '/settings/account' => 'devise/registrations#update'
    delete '/settings/account' => 'user/registrations#destroy'
  end

  namespace :settings do
    get :theme, to: redirect('/settings/theme/edit')
    resource :theme, controller: :theme, only: %i[edit update destroy]

    get :profile, to: redirect('/settings/profile/edit')
    resource :profile, controller: :profile, only: %i[edit update]

    resource :profile_picture, controller: :profile_picture, only: %i[update]

    get :privacy, to: redirect('/settings/privacy/edit')
    resource :privacy, controller: :privacy, only: %i[edit update]

    get :export, to: 'export#index'
    post :export, to: 'export#create'

    get :muted, to: 'mutes#index'

    get :blocks, to: 'blocks#index'

    get :data, to: 'data#index'

    namespace :two_factor_authentication do
      get :otp_authentication, to: 'otp_authentication#index'
      patch :otp_authentication, to: 'otp_authentication#update'
      delete :otp_authentication, to: 'otp_authentication#destroy'
      match 'otp_authentication/reset', to: 'otp_authentication#reset', via: :delete
    end
  end
  resolve('Theme') { [:settings_theme] } # to make link_to/form_for work nicely when passing a `Theme` object to it, see also: https://api.rubyonrails.org/v6.1.5.1/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
  resolve('Profile') { [:settings_profile] }

  # resources :services, only: [:index, :destroy]
  match '/settings/services', to: 'services#index', via: 'get', as: :services
  match '/settings/services/:id', to: 'services#update', via: 'patch', as: :update_service
  match '/settings/services/:id', to: 'services#destroy', via: 'delete', as: :service
  controller :services do
    scope "/auth", as: "auth" do
      get ':provider/callback' => :create
      get :failure
    end
  end

  namespace :ajax do
    match '/ask', to: 'question#create', via: :post, as: :ask
    match '/destroy_question', to: 'question#destroy', via: :post, as: :destroy_question
    match '/generate_question', to: 'inbox#create', via: :post, as: :generate_question
    match '/delete_inbox', to: 'inbox#remove', via: :post, as: :delete_inbox
    match '/delete_all_inbox', to: 'inbox#remove_all', via: :post, as: :delete_all_inbox
    match '/delete_all_inbox/:author', to: 'inbox#remove_all_author', via: :post, as: :delete_all_author
    match '/answer', to: 'answer#create', via: :post, as: :answer
    match '/destroy_answer', to: 'answer#destroy', via: :post, as: :destroy_answer
    match '/create_relationship', to: 'relationship#create', via: :post, as: :create_relationship
    match '/destroy_relationship', to: 'relationship#destroy', via: :post, as: :destroy_relationship
    match '/create_smile', to: 'smile#create', via: :post, as: :create_smile
    match '/destroy_smile', to: 'smile#destroy', via: :post, as: :destroy_smile
    match '/create_comment_smile', to: 'smile#create_comment', via: :post, as: :create_comment_smile
    match '/destroy_comment_smile', to: 'smile#destroy_comment', via: :post, as: :destroy_comment_smile
    match '/create_comment', to: 'comment#create', via: :post, as: :create_comment
    match '/destroy_comment', to: 'comment#destroy', via: :post, as: :destroy_comment
    match '/report', to: 'report#create', via: :post, as: :report
    match '/create_list', to: 'list#create', via: :post, as: :create_list
    match '/destroy_list', to: 'list#destroy', via: :post, as: :destroy_list
    match '/list_membership', to: 'list#membership', via: :post, as: :list_membership
    match '/subscribe', to: 'subscription#subscribe', via: :post, as: :subscribe_answer
    match '/unsubscribe', to: 'subscription#unsubscribe', via: :post, as: :unsubscribe_answer
    match '/mute', to: 'mute_rule#create', via: :post, as: :create_mute_rule
    match '/mute/:id', to: 'mute_rule#update', via: :post, as: :update_mute_rule
    match '/mute/:id', to: 'mute_rule#destroy', via: :delete, as: :delete_mute_rule
    match '/block_anon', to: 'anonymous_block#create', via: :post, as: :block_anon
    match '/block_anon/:id', to: 'anonymous_block#destroy', via: :delete, as: :unblock_anon
  end

  match '/discover', to: 'discover#index', via: :get, as: :discover
  match '/public', to: 'timeline#public', via: :get, as: :public_timeline if APP_CONFIG.dig(:features, :public, :enabled)
  match '/list/:list_name', to: 'timeline#list', via: :get, as: :list_timeline

  match '/notifications(/:type)', to: 'notifications#index', via: :get, as: :notifications, defaults: {type: 'new'}

  match '/inbox', to: 'inbox#show', via: 'get'
  match '/inbox/:author', to: 'inbox#show', via: 'get'

  match '/user/:username(/p/:page)', to: 'user#show', via: 'get', defaults: {page: 1}
  match '/@:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile_alt, defaults: {page: 1}
  match '/@:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer_alt
  match '/@:username/q/:id', to: 'question#show', via: 'get', as: :show_user_question_alt
  match '/@:username/followers(/p/:page)', to: 'user#followers', via: 'get', as: :show_user_followers_alt, defaults: {page: 1}
  match '/@:username/followings(/p/:page)', to: 'user#followings', via: 'get', as: :show_user_followings_alt, defaults: {page: 1}
  match '/@:username/friends(/p/:page)', to: redirect('/@%{username}/followings/p/%{page}'), via: 'get', defaults: {page: 1}
  match '/:username(/p/:page)', to: 'user#show', via: 'get', as: :show_user_profile, defaults: {page: 1}
  match '/:username/a/:id', to: 'answer#show', via: 'get', as: :show_user_answer
  match '/:username/q/:id', to: 'question#show', via: 'get', as: :show_user_question
  match '/:username/followers(/p/:page)', to: 'user#followers', via: 'get', as: :show_user_followers, defaults: {page: 1}
  match '/:username/followings(/p/:page)', to: 'user#followings', via: 'get', as: :show_user_followings, defaults: {page: 1}
  match '/:username/friends(/p/:page)', to: redirect('/%{username}/followings/p/%{page}'), via: 'get', defaults: {page: 1}
  match '/:username/questions(/p/:page)', to: 'user#questions', via: 'get', as: :show_user_questions, defaults: {page: 1}

  match '/feedback/consent', to: 'feedback#consent', via: 'get', as: 'feedback_consent'
  match '/feedback/consent/update', to: 'feedback#update', via: 'post', as: 'feedback_consent_update'
  match '/feedback/bugs(/*any)', to: 'feedback#bugs', via: 'get', as: 'feedback_bugs'
  match '/feedback/feature_requests(/*any)', to: 'feedback#features', via: 'get', as: 'feedback_features'

  get '/.well-known/change-password', to: redirect('/settings/account')

  puts 'processing time of routes.rb: ' + "#{(Time.now - start).round(3).to_s.ljust(5, '0')}s".light_green
end
