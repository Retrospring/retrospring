class Question < ActiveRecord::Base
  belongs_to :user
  has_one :answer
end
