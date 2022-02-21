class User < ApplicationRecord
  include User::Relationship
  include User::Relationship::Follow
  include User::AnswerMethods
  include User::InboxMethods
  include User::QuestionMethods
  include User::RelationshipMethods
  include User::TimelineMethods
  include ActiveModel::OneTimePassword

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable, :authentication_keys => [:login]

  has_one_time_password
  enum otp_module: { disabled: 0, enabled: 1 }, _prefix: true
  attr_accessor :otp_attempt, :otp_validation

  enum email_notify_on_new_inbox: {
    never:       0,
    immediately: 1,
    hourly:      2,
    daily:       3
  }, _prefix: true

  rolify

#   attr_accessor :login

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :inboxes, dependent: :destroy
  has_many :smiles, dependent: :destroy
  has_many :comment_smiles, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :moderation_comments, dependent: :destroy
  has_many :moderation_votes, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :list_memberships, class_name: "ListMember", foreign_key: 'user_id', dependent: :destroy
  has_many :mute_rules, dependent: :destroy

  has_many :subscriptions, dependent: :destroy
  has_many :totp_recovery_codes, dependent: :destroy

  has_one :profile, dependent: :destroy
  has_one :theme, dependent: :destroy

  has_many :bans, class_name: 'UserBan', dependent: :destroy
  has_many :banned_users, class_name: 'UserBan',
                          foreign_key: 'banned_by_id',
                          dependent: :nullify

  SCREEN_NAME_REGEX = /\A[a-zA-Z0-9_]{1,16}\z/
  WEBSITE_REGEX = /https?:\/\/([A-Za-z.\-]+)\/?(?:.*)/i

  before_validation do
    screen_name.strip!
  end

  validates :email, fake_email: true, typoed_email: true
  validates :screen_name, presence: true, format: { with: SCREEN_NAME_REGEX }, uniqueness: { case_sensitive: false }, screen_name: true

  mount_uploader :profile_picture, ProfilePictureUploader, mount_on: :profile_picture_file_name
  process_in_background :profile_picture
  mount_uploader :profile_header, ProfileHeaderUploader, mount_on: :profile_header_file_name
  process_in_background :profile_header

  # when a user has been deleted, all reports relating to the user become invalid
  before_destroy do
    rep = Report.where(target_id: self.id, type: 'Reports::User')
    rep.each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end
  end

  after_create do
    Profile.create(user_id: id) if Profile.where(user_id: id).count.zero?
  end

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

  # @param list [List]
  # @return [Boolean] true if +self+ is a member of +list+
  def member_of?(list)
    list_memberships.pluck(:list_id).include? list.id
  end

  # answers a question
  # @param question [Question] the question to answer
  # @param content [String] the answer content
  def answer(question, content)
    Answer.create!(content: content,
                   user: self,
                   question: question)
  end

  # has the user answered +question+ yet?
  # @param question [Question]
  def answered?(question)
    question.answers.pluck(:user_id).include? self.id
  end

  # smiles an answer
  # @param answer [Answer] the answer to smile
  def smile(answer)
    Smile.create!(user: self, answer: answer)
  end

  # unsmile an answer
  # @param answer [Answer] the answer to unsmile
  def unsmile(answer)
    Smile.find_by(user: self, answer: answer).destroy
  end

  # smiles a comment
  # @param comment [Comment] the comment to smile
  def smile_comment(comment)
    CommentSmile.create!(user: self, comment: comment)
  end

  # unsmile an comment
  # @param comment [Comment] the comment to unsmile
  def unsmile_comment(comment)
    CommentSmile.find_by(user: self, comment: comment).destroy
  end

  def smiled?(answer)
    answer.smiles.pluck(:user_id).include? self.id
  end

  def smiled_comment?(comment)
    comment.smiles.pluck(:user_id).include? self.id
  end

  def comment(answer, content)
    Comment.create!(user: self, answer: answer, content: content)
  end

  # @return [Boolean] is the user a moderator?
  def mod?
    has_role?(:moderator) || has_role?(:administrator)
  end

  # region stuff used for reporting/moderation
  def report(object, reason = nil)
    existing = Report.find_by(type: "Reports::#{object.class}", target_id: object.id, user_id: self.id, deleted: false)
    if existing.nil?
      Report.create(type: "Reports::#{object.class}", target_id: object.id, user_id: self.id, reason: reason)
    elsif not reason.nil? and reason.length > 0
      if existing.reason.nil?
        existing.update(reason: reason)
      else
        existing.update(reason: [existing.reason || "", reason].join("\n"))
      end
    else
      existing
    end
  end

  # @param upvote [Boolean]
  def report_vote(report, upvote = false)
    return unless mod?
    ModerationVote.create!(user: self, report: report, upvote: upvote)
  end

  def report_unvote(report)
    return unless mod?
    ModerationVote.find_by(user: self, report: report).destroy
  end

  def report_voted?(report)
    return false unless mod?
    report.moderation_votes.each { |s| return true if s.user_id == self.id }
    false
  end

  # @param upvote [Boolean]
  def report_x_voted?(report, upvote)
    return false unless mod?
    report.moderation_votes.where(upvote: upvote).each { |s| return true if s.user_id == self.id }
    false
  end

  def report_comment(report, content)
    ModerationComment.create!(user: self, report: report, content: content)
  end
  # endregion

  def banned?
    self.bans.current.count > 0
  end

  def unban
    UseCase::User::Unban.call(id)
  end

  # Bans a user.
  # @param duration [Integer?] Ban duration
  # @param duration_unit [String, nil] Unit for the <code>duration</code> parameter. Accepted units: hours, days, weeks, months
  # @param reason [String] Reason for the ban. This is displayed to the user.
  # @param banned_by [User] User who instated the ban
  def ban(duration, duration_unit = 'hours', reason = nil, banned_by = nil)
    if duration
      expiry = duration.public_send(duration_unit)
    else
      expiry = nil
    end
    UseCase::User::Ban.call(
      target_user_id: id,
      expiry: expiry,
      reason: reason,
      source_user_id: banned_by&.id
    )
  end

  def can_export?
    unless self.export_created_at.nil?
      return (Time.now > self.export_created_at.in(1.week)) && !self.export_processing
    end
    !self.export_processing
  end

  # %w[admin moderator].each do |m|
  #   define_method(m) { raise "not allowed: #{m}" }
  #   define_method(m+??) { raise "not allowed: #{m}?"}
  #   define_method(m+?=) { |*a| raise "not allowed: #{m}="}
  # end
end
