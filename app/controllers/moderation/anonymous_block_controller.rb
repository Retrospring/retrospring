# frozen_string_literal: true

class Moderation::AnonymousBlockController < ApplicationController
  def index
    @anonymous_blocks = AnonymousBlock.where(user: nil)
  end
end
