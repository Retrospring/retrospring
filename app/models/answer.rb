class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :comments
end
