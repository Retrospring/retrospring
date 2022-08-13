class Moderation::AnonymousBlockController < ApplicationController
  def index
    @anonymous_blocks = AnonymousBlock.where(user: nil)
  end
end
