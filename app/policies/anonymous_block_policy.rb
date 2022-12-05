# frozen_string_literal: true

class AnonymousBlockPolicy
  attr_reader :user, :anonymous_block

  def initialize(user, anonymous_block)
    @user = user
    @anonymous_block = anonymous_block
  end

  def create_global?
    user.mod?
  end

  def destroy?
    user == anonymous_block.user || user.mod?
  end
end
