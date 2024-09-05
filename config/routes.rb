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
  end

  root to: "about#index"

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
    get "/settings/account" => "devise/registrations#edit", :as => :edit_user_registration
    patch "/settings/account" => "devise/registrations#update", :as => :update_user_registration
    put "/settings/account" => "devise/registrations#update"
    delete "/settings/account" => "user/registrations#destroy"
  end

  namespace :settings do
    get :export, to: "export#index"
    post :export, to: "export#create"
  end

  resource :anonymous_block, controller: :anonymous_block, only: %i[create destroy]

  namespace :well_known, path: "/.well-known" do
    get "/change-password", to: redirect("/settings/account")
    get "/nodeinfo", to: "node_info#discovery"
  end

  get "/nodeinfo/2.1", to: "well_known/node_info#nodeinfo", as: :node_info

  get "/modal/close", to: "modal#close", as: :modal_close

  puts "processing time of routes.rb: #{"#{(Time.zone.now - start).round(3).to_s.ljust(5, '0')}s".light_green}"
end
