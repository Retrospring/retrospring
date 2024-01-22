# frozen_string_literal: true

require "web-push"

class AddWebpushApp < ActiveRecord::Migration[6.1]
  def up
    vapid_keypair = WebPush.generate_key.to_hash
    app = Rpush::Webpush::App.new
    app.name = "webpush"
    app.certificate = vapid_keypair.merge(subject: APP_CONFIG.fetch("contact_email")).to_json
    app.connections = 1
    app.save!
  end

  def down
    Rpush::Webpush::App.find_by(name: "webpush").destroy!
  end
end
