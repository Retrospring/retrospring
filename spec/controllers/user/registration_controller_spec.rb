# frozen_string_literal: true

require "rails_helper"

describe User::RegistrationsController, type: :controller do
  before do
    # Required for devise to register routes
    @request.env["devise.mapping"] = Devise.mappings[:user]

    stub_const("APP_CONFIG", {
                 "hostname"               => "example.com",
                 "https"                  => true,
                 "items_per_page"         => 5,
                 "forbidden_screen_names" => %w[
                   justask_admin retrospring_admin admin justask retrospring
                   moderation moderator mod administrator siteadmin site_admin
                   help retro_spring retroospring retrosprlng
                 ],
               },)
  end
end
