class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :authentication_keys => [:login]

#   attr_accessor :login

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :inboxes, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'source_id',
                                  dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'target_id',
                                   dependent: :destroy
  has_many :friends,   through: :active_relationships, source: :target
  has_many :followers, through: :passive_relationships, source: :source
  has_many :smiles
  has_many :services
  has_many :notifications, foreign_key: :recipient_id

  SCREEN_NAME_REGEX = /\A[a-zA-Z0-9_]{1,16}\z/
  WEBSITE_REGEX = /https?:\/\/([A-Za-z.\-]+)\/?(?:.*)/i

  validates :screen_name, presence: true, format: { with: SCREEN_NAME_REGEX }, uniqueness: { case_sensitive: false }

  validates :display_name, length: { maximum: 50 }

  # validates :website, format: { with: WEBSITE_REGEX }

  def login=(login)
    @login = login
  end

  def login
    @login || self.screen_name || self.email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(screen_name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  # @return [Array] the users' timeline
  def timeline
    Answer.where("user_id in (?) OR user_id = ?", friend_ids, id).order(:created_at).reverse_order
  end

  # follows an user.
  def follow(target_user)
    relationship = active_relationships.create(target: target_user)
    Notification.notify target_user, relationship

    # increment counts
    increment! :friend_count
    target_user.increment! :follower_count
  end

  # unfollows an user
  def unfollow(target_user)
    active_relationships.find_by(target: target_user).destroy

    # decrement counts
    decrement! :friend_count
    target_user.decrement! :follower_count
  end

  # @return [Boolean] true if +self+ is following +target_user+
  def following?(target_user)
    friends.include? target_user
  end

  # smiles an answer
  # @param answer [Answer] the answer to smile
  def smile(answer)
    smile = Smile.create(user: self, answer: answer)
    Notification.notify answer.user, smile unless answer.user == self
    increment! :smiled_count
    answer.increment! :smile_count
  end

  # unsmile an answer
  # @param answer [Answer] the answer to unsmile
  def unsmile(answer)
    Smile.find_by(user: self, answer: answer).destroy
    decrement! :smiled_count
    answer.decrement! :smile_count
  end

  def smiled?(answer)
    # TODO: you know what to do here, nilsding
    answer.smiles.each { |s| return true if s.user_id == self.id }
    false
  end

  def display_website
    website.match(/https?:\/\/([A-Za-z.\-]+)\/?(?:.*)/i)[1]
  rescue NoMethodError
    website
  end

  def comment(answer, content)
    comment = Comment.create!(user: self, answer: answer, content: content)
    Notification.notify answer.user, comment unless answer.user == self
    increment! :commented_count
    answer.increment! :comment_count
  end
end
