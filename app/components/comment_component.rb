# frozen_string_literal: true

class CommentComponent < ApplicationComponent
  include ApplicationHelper
  include BootstrapHelper
  include UserHelper

  def initialize(comment:, answer:)
    @comment = comment
    @answer = answer
  end
end
