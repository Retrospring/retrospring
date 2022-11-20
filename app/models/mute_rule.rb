class MuteRule < ApplicationRecord
  belongs_to :user

  validates_presence_of :muted_phrase

  def applies_to?(post)
    !!(post.content =~ /\b#{Regexp.escape(muted_phrase)}\b/i)
  end
end
