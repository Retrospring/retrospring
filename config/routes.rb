# frozen_string_literal: true

require "sidekiq/web"
Rails.application.routes.draw do
  start = Time.zone.now

  # Routes only accessible by admins (admin panels, sidekiq, pghero)
  authenticate :user, ->(user) { user.has_role?(:administrator) } do
    # Admin panel
    mount RailsAdmin::Engine => "/justask_admin", :as => "rails_admin"

    mount Sidekiq::Web, at: "/sidekiq"
    mount PgHero::Engine, at: "/pghero", as: "pghero"

    get "/admin/announcements", to: "announcement#index", as: :announcement_index
    post "/admin/announcements", to: "announcement#create", as: :announcement_create
    get "/admin/announcements/new", to: "announcement#new", as: :announcement_new
    get "/admin/announcements/:id/edit", to: "announcement#edit", as: :announcement_edit
    patch "/admin/announcements/:id", to: "announcement#update", as: :announcement_update
    delete "/admin/announcements/:id", to: "announcement#destroy", as: :announcement_destroy
  end

  # Routes only accessible by moderators (moderation panel)
  authenticate :user, ->(user) { user.mod? } do
    post "/moderation/unmask", to: "moderation#toggle_unmask", as: :moderation_toggle_unmask
    get "/moderation/blocks", to: "moderation/anonymous_block#index", as: :mod_anon_block_index
    get "/moderation/reports(/:type)", to: "moderation/reports#index", as: :moderation_reports, defaults: { type: "all" }
    get "/moderation/inbox/:user", to: "moderation/inbox#index", as: :mod_inbox_index
    get "/moderation/questions/:author_identifier", to: "moderation/questions#show", as: :moderation_questions
    namespace :ajax do
      post "/mod/destroy_report", to: "moderation#destroy_report", as: :mod_destroy_report
      post "/mod/privilege", to: "moderation#privilege", as: :mod_privilege
      post "/mod/ban", to: "moderation#ban", as: :mod_ban
    end
  end

  unauthenticated :user do
    root to: "about#index"
  end

  authenticate :user do
    root to: "timeline#index", as: :timeline
  end

  get "/about", to: "about#about"
  get "/privacy", to: "about#privacy_policy", as: :privacy_policy
  get "/terms", to: "about#terms", as: :terms
  get "/linkfilter", to: "link_filter#index", as: :linkfilter
  get "/manifest.json", to: "manifests#show", as: :webapp_manifest

  # Devise routes
  devise_for :users, path: "user", skip: %i[sessions registrations]
  as :user do
    # :sessions
    get "sign_in" => "user/sessions#new", :as => :new_user_session
    post "sign_in" => "user/sessions#create", :as => :user_session
    delete "sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
    # :registrations
    get "settings/delete_account" => "devise/registrations#cancel", :as => :cancel_user_registration
    post "/user/create" => "user/registrations#create", :as => :user_registration
    get "/sign_up" => "devise/registrations#new", :as => :new_user_registration
    get "/settings/account" => "devise/registrations#edit", :as => :edit_user_registration
    patch "/settings/account" => "devise/registrations#update", :as => :update_user_registration
    put "/settings/account" => "devise/registrations#update"
    delete "/settings/account" => "user/registrations#destroy"
  end

  namespace :settings do
    get :theme, to: redirect("/settings/theme/edit")
    resource :theme, controller: :theme, only: %i[edit update destroy]

    get :profile, to: redirect("/settings/profile/edit")
    resource :profile, controller: :profile, only: %i[edit update]

    resource :profile_picture, controller: :profile_picture, only: %i[update]

    get :privacy, to: redirect("/settings/privacy/edit")
    resource :privacy, controller: :privacy, only: %i[edit update]

    get :export, to: "export#index"
    post :export, to: "export#create"

    get :muted, to: "mutes#index"

    get :blocks, to: "blocks#index"

    get :data, to: "data#index"

    namespace :two_factor_authentication do
      get :otp_authentication, to: "otp_authentication#index"
      patch :otp_authentication, to: "otp_authentication#update"
      delete :otp_authentication, to: "otp_authentication#destroy"
      delete "otp_authentication/reset", to: "otp_authentication#reset"
    end
  end
  resolve("Theme") { [:settings_theme] } # to make link_to/form_for work nicely when passing a `Theme` object to it, see also: https://api.rubyonrails.org/v6.1.5.1/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
  resolve("Profile") { [:settings_profile] }

  # resources :services, only: [:index, :destroy]
  get "/settings/services", to: "services#index", as: :services
  patch "/settings/services/:id", to: "services#update", as: :update_service
  delete "/settings/services/:id", to: "services#destroy", as: :service
  controller :services do
    scope "/auth", as: "auth" do
      get ":provider/callback" => :create
      get :failure
    end
  end

  namespace :ajax do
    post "/ask", to: "question#create", as: :ask
    post "/destroy_question", to: "question#destroy", as: :destroy_question
    post "/generate_question", to: "inbox#create", as: :generate_question
    post "/delete_inbox", to: "inbox#remove", as: :delete_inbox
    post "/delete_all_inbox", to: "inbox#remove_all", as: :delete_all_inbox
    post "/delete_all_inbox/:author", to: "inbox#remove_all_author", as: :delete_all_author
    post "/answer", to: "answer#create", as: :answer
    post "/destroy_answer", to: "answer#destroy", as: :destroy_answer
    post "/create_relationship", to: "relationship#create", as: :create_relationship
    post "/destroy_relationship", to: "relationship#destroy", as: :destroy_relationship
    post "/create_smile", to: "smile#create", as: :create_smile
    post "/destroy_smile", to: "smile#destroy", as: :destroy_smile
    post "/create_comment_smile", to: "smile#create_comment", as: :create_comment_smile
    post "/destroy_comment_smile", to: "smile#destroy_comment", as: :destroy_comment_smile
    post "/create_comment", to: "comment#create", as: :create_comment
    post "/destroy_comment", to: "comment#destroy", as: :destroy_comment
    post "/report", to: "report#create", as: :report
    post "/create_list", to: "list#create", as: :create_list
    post "/destroy_list", to: "list#destroy", as: :destroy_list
    post "/list_membership", to: "list#membership", as: :list_membership
    post "/subscribe", to: "subscription#subscribe", as: :subscribe_answer
    post "/unsubscribe", to: "subscription#unsubscribe", as: :unsubscribe_answer
    post "/mute", to: "mute_rule#create", as: :create_mute_rule
    post "/mute/:id", to: "mute_rule#update", as: :update_mute_rule
    delete "/mute/:id", to: "mute_rule#destroy", as: :delete_mute_rule
    post "/block_anon", to: "anonymous_block#create", as: :block_anon
    delete "/block_anon/:id", to: "anonymous_block#destroy", as: :unblock_anon
  end

  get "/discover", to: "discover#index", as: :discover
  get "/public", to: "timeline#public", as: :public_timeline if APP_CONFIG.dig(:features, :public, :enabled)
  get "/list/:list_name", to: "timeline#list", as: :list_timeline

  get "/notifications(/:type)", to: "notifications#index", as: :notifications, defaults: { type: "new" }

  get "/inbox", to: "inbox#show"
  get "/inbox/:author", to: "inbox#show"

  get "/user/:username(/p/:page)", to: "user#show", defaults: { page: 1 }
  get "/@:username(/p/:page)", to: "user#show", as: :user, defaults: { page: 1 }
  get "/@:username/a/:id", to: "answer#show", via: "get", as: :answer
  get "/@:username/q/:id", to: "question#show", via: "get", as: :question
  get "/@:username/followers(/p/:page)", to: "user#followers", as: :show_user_followers, defaults: { page: 1 }
  get "/@:username/followings(/p/:page)", to: "user#followings", as: :show_user_followings, defaults: { page: 1 }
  get "/@:username/friends(/p/:page)", to: redirect("/@%{username}/followings/p/%{page}"), defaults: { page: 1 }
  get "/@:username/questions(/p/:page)", to: "user#questions", as: :show_user_questions, defaults: { page: 1 }
  get "/:username(/p/:page)", to: "user#show", as: :user_alt, defaults: { page: 1 }
  get "/:username/a/:id", to: "answer#show", as: :answer_alt
  get "/:username/q/:id", to: "question#show", as: :question_alt
  get "/:username/followers(/p/:page)", to: "user#followers", as: :show_user_followers_alt, defaults: { page: 1 }
  get "/:username/followings(/p/:page)", to: "user#followings", as: :show_user_followings_alt, defaults: { page: 1 }
  get "/:username/friends(/p/:page)", to: redirect("/%{username}/followings/p/%{page}"), defaults: { page: 1 }
  get "/:username/questions(/p/:page)", to: "user#questions", as: :show_user_questions_alt, defaults: { page: 1 }

  get "/feedback/consent", to: "feedback#consent", as: "feedback_consent"
  post "/feedback/consent/update", to: "feedback#update", as: "feedback_consent_update"
  get "/feedback/bugs(/*any)", to: "feedback#bugs", as: "feedback_bugs"
  get "/feedback/feature_requests(/*any)", to: "feedback#features", as: "feedback_features"

  get "/.well-known/change-password", to: redirect("/settings/account")

  puts "processing time of routes.rb: #{"#{(Time.zone.now - start).round(3).to_s.ljust(5, '0')}s".light_green}"
end
