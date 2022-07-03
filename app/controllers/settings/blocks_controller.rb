# frozen_string_literal: true

class Settings::BlocksController < ApplicationController
  before_action :authenticate_user!

  def index
    @blocks = Relationships::Block.where(source: current_user)
    @anonymous_blocks = AnonymousBlock.where(user: current_user)
  end
end
