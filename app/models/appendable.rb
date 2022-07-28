# frozen_string_literal: true

class Appendable < ApplicationRecord
  include Discard::Model

  belongs_to :parent, polymorphic: true
  belongs_to :user
end
