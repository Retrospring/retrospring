# frozen_string_literal: true

class Appendable < ApplicationRecord
  belongs_to :parent, polymorphic: true
  belongs_to :user
end
