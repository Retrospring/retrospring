# frozen_string_literal: true

class Appendable < ApplicationRecord
  acts_as_paranoid

  belongs_to :parent, polymorphic: true
  belongs_to :user
end
