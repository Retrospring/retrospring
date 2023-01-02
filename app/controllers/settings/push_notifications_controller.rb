# frozen_string_literal: true

class Settings::PushNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subscriptions = current_user.web_push_subscriptions.active
  end
end
