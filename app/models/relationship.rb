class Relationship < ActiveRecord::Base
  belongs_to :source, class_name: 'User'
  belongs_to :target, class_name: 'User'
  validates :source_id, presence: true
  validates :target_id, presence: true
end
