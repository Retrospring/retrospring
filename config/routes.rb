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

    get "/admin", to: "admin/dashboard#index", as: :admin_dashboard
    get "/admin/announcements", to: "admin/announcement#index", as: :announcement_index
    post "/admin/announcements", to: "admin/announcement#create", as: :announcement_create
    get "/admin/announcements/new", to: "admin/announcement#new", as: :announcement_new
    get "/admin/announcements/:id/edit", to: "admin/announcement#edit", as: :announcement_edit
    patch "/admin/announcements/:id", to: "admin/announcement#update", as: :announcement_update
    delete "/admin/announcements/:id", to: "admin/announcement#destroy", as: :announcement_destroy
  end

  # Routes only accessible by moderators (moderation panel)
  authenticate :user, ->(user) { user.mod? } do
    post "/moderation/unmask", to: "moderation#toggle_unmask", as: :moderation_toggle_unmask
    get "/moderation/blocks", to: "moderation/anonymous_block#index", as: :mod_anon_block_index
    get "/moderation/inbox/:user", to: "moderation/inbox#index", as: :mod_inbox_index
    get "/moderation/reports(/:type)", to: "moderation/reports#index", as: :moderation_reports, defaults: { type: "all" }
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

  constraints(Constraints::LocalNetwork) do
    get "/metrics", to: "metrics#show"
  end

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

    get :sharing, to: redirect("/settings/sharing/edit")
    resource :sharing, controller: :sharing, only: %i[edit update]

    get :export, to: "export#index"
    post :export, to: "export#create"

    get :muted, to: "mutes#index"
    post :muted, to: "mutes#create"
    delete "muted/:id", to: "mutes#destroy", as: :muted_destroy

    get :blocks, to: "blocks#index"

    get :data, to: "data#index"

    resources :push_notifications, only: %i[index]

    namespace :two_factor_authentication do
      get :otp_authentication, to: "otp_authentication#index"
      patch :otp_authentication, to: "otp_authentication#update"
      delete :otp_authentication, to: "otp_authentication#destroy"
      delete "otp_authentication/reset", to: "otp_authentication#reset"
    end
  end
  resolve("Theme") { [:settings_theme] } # to make link_to/form_for work nicely when passing a `Theme` object to it, see also: https://api.rubyonrails.org/v6.1.5.1/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
  resolve("Profile") { [:settings_profile] }

  namespace :ajax do
    post "/ask", to: "question#create", as: :ask
    post "/destroy_question", to: "question#destroy", as: :destroy_question
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
    get "/webpush/key", to: "web_push#key", as: :webpush_key
    post "/webpush/check", to: "web_push#check", as: :webpush_check
    post "/webpush", to: "web_push#subscribe", as: :webpush_subscribe
    delete "/webpush", to: "web_push#unsubscribe", as: :webpush_unsubscribe
  end

  resource :anonymous_block, controller: :anonymous_block, only: %i[create destroy]

  get "/discover", to: "discover#index", as: :discover
  get "/public", to: "timeline#public", as: :public_timeline if APP_CONFIG.dig(:features, :public, :enabled)
  get "/list/:list_name", to: "timeline#list", as: :list_timeline

  get "/notifications(/:type)", to: "notifications#index", as: :notifications, defaults: { type: "new" }
  post "/notifications", to: "notifications#read", as: :notifications_read

  post "/inbox/create", to: "inbox#create", as: :inbox_create
  get "/inbox", to: "inbox#show", as: :inbox

  get "/search", to: "search#index"

  get "/user/:username", to: "user#show"
  get "/@:username", to: "user#show", as: :user
  get "/@:username/a/:id", to: "answer#show", as: :answer
  post "/@:username/a/:id/pin", to: "answer#pin", as: :pin_answer
  delete "/@:username/a/:id/pin", to: "answer#unpin", as: :unpin_answer
  get "/@:username/a/:id/comments", to: "comment#index", as: :comments
  get "/@:username/a/:id/reactions", to: "reaction#index", as: :reactions
  get "/@:username/q/:id", to: "question#show", as: :question
  get "/@:username/followers", to: "user#followers", as: :show_user_followers
  get "/@:username/followings", to: "user#followings", as: :show_user_followings
  get "/@:username/friends", to: redirect("/@%{username}/followings")
  get "/@:username/questions", to: "user#questions", as: :show_user_questions
  get "/:username", to: "user#show", as: :user_alt
  get "/:username/a/:id", to: "answer#show", as: :answer_alt
  get "/:username/q/:id", to: "question#show", as: :question_alt
  get "/:username/followers", to: "user#followers", as: :show_user_followers_alt
  get "/:username/followings", to: "user#followings", as: :show_user_followings_alt
  get "/:username/friends", to: redirect("/%{username}/followings")
  get "/:username/questions", to: "user#questions", as: :show_user_questions_alt

  get "/feedback/consent", to: "feedback#consent", as: "feedback_consent"
  post "/feedback/consent/update", to: "feedback#update", as: "feedback_consent_update"
  get "/feedback/bugs(/*any)", to: "feedback#bugs", as: "feedback_bugs"
  get "/feedback/feature_requests(/*any)", to: "feedback#features", as: "feedback_features"

  namespace :well_known, path: "/.well-known" do
    get "/change-password", to: redirect("/settings/account")
    get "/nodeinfo", to: "node_info#discovery"
  end

  get "/nodeinfo/2.1", to: "well_known/node_info#nodeinfo", as: :node_info

  puts "processing time of routes.rb: #{"#{(Time.zone.now - start).round(3).to_s.ljust(5, '0')}s".light_green}"
end
