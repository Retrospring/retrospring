class Inbox < ActiveRecord::Base
  belongs_to :user
  has_one :question
end
