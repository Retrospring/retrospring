# frozen_string_literal: true

class MuteRule < ApplicationRecord
  belongs_to :user

  validates :muted_phrase, length: { minimum: 1 }

  def applies_to?(post)
    !!(post.content =~ /\b#{Regexp.escape(muted_phrase)}\b/i)
  end
end
