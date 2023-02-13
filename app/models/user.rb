# frozen_string_literal: true

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include User::Relationship
  include User::Relationship::Follow
  include User::Relationship::Block
  include User::Relationship::Mute
  include User::AnswerMethods
  include User::BanMethods
  include User::InboxMethods
  include User::QuestionMethods
  include User::PushNotificationMethods
  include User::ReactionMethods
  include User::RelationshipMethods
  include User::SharingMethods
  include User::TimelineMethods
  include ActiveModel::OneTimePassword

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable, authentication_keys: [:login]

  has_one_time_password
  enum otp_module: { disabled: 0, enabled: 1 }, _prefix: true
  attr_accessor :otp_attempt, :otp_validation
  attr_writer :login

  rolify

  has_many :questions, dependent: :destroy_async
  has_many :answers, dependent: :destroy_async
  has_many :comments, dependent: :destroy_async
  has_many :inboxes, dependent: :destroy_async
  has_many :smiles, class_name: "Appendable::Reaction", dependent: :destroy_async
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy_async
  has_many :reports, dependent: :destroy_async
  has_many :lists, dependent: :destroy_async
  has_many :list_memberships, class_name: "ListMember", dependent: :destroy_async
  has_many :mute_rules, dependent: :destroy_async
  has_many :anonymous_blocks, dependent: :destroy_async

  has_many :subscriptions, dependent: :destroy_async
  has_many :totp_recovery_codes, dependent: :destroy_async
  has_many :web_push_subscriptions, dependent: :destroy_async

  has_one :profile, dependent: :destroy
  has_one :theme, dependent: :destroy

  has_many :bans, class_name: "UserBan", dependent: :destroy_async
  has_many :banned_users, class_name:  "UserBan",
                          foreign_key: "banned_by_id",
                          dependent:   :nullify

  SCREEN_NAME_REGEX = /\A[a-zA-Z0-9_]+\z/
  WEBSITE_REGEX = /https?:\/\/([A-Za-z.-]+)\/?(?:.*)/i

  before_validation do
    screen_name.strip!
  end

  validates :email, fake_email: true, typoed_email: true
  validates :sharing_custom_url, allow_blank: true, valid_url: true
  validates :screen_name,
            presence:    true,
            format:      { with: SCREEN_NAME_REGEX, message: I18n.t("activerecord.validation.user.screen_name.format") },
            length:      { minimum: 1, maximum: 16 },
            uniqueness:  { case_sensitive: false },
            screen_name: true

  mount_uploader :profile_picture, ProfilePictureUploader, mount_on: :profile_picture_file_name
  process_in_background :profile_picture
  mount_uploader :profile_header, ProfileHeaderUploader, mount_on: :profile_header_file_name
  process_in_background :profile_header

  # when a user has been deleted, all reports relating to the user become invalid
  before_destroy do
    Report.where(target_id: id, type: "Reports::User").find_each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end
  end

  after_create do
    Profile.create(user_id: id) if Profile.where(user_id: id).count.zero?
  end

  # use the screen name as parameter for url helpers
  def to_param = screen_name

  def login = @login || screen_name || email

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions).where(["lower(screen_name) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  # @param list [List]
  # @return [Boolean] true if +self+ is a member of +list+
  def member_of?(list) = list_memberships.pluck(:list_id).include? list.id

  # answers a question
  # @param question [Question] the question to answer
  # @param content [String] the answer content
  def answer(question, content)
    # rubocop:disable Style/RedundantSelf
    raise Errors::AnsweringOtherBlockedSelf if question.user&.blocking?(self)
    raise Errors::AnsweringSelfBlockedOther if self.blocking?(question.user)
    # rubocop:enable Style/RedundantSelf

    Retrospring::Metrics::QUESTIONS_ANSWERED.increment

    Answer.create!(content:, user: self, question:)
  end

  # has the user answered +question+ yet?
  # @param question [Question]
  def answered?(question) = question.answers.pluck(:user_id).include? id

  def comment(answer, content)
    # rubocop:disable Style/RedundantSelf
    raise Errors::CommentingSelfBlockedOther if self.blocking?(answer.user)
    raise Errors::CommentingOtherBlockedSelf if answer.user.blocking?(self)
    # rubocop:enable Style/RedundantSelf

    Retrospring::Metrics::COMMENTS_CREATED.increment

    Comment.create!(user: self, answer:, content:)
  end

  # @return [Boolean] is the user a moderator?
  def mod? = has_cached_role?(:moderator) || has_cached_role?(:administrator)

  def admin? = has_cached_role?(:administrator)

  # region stuff used for reporting/moderation
  def report(object, reason = nil)
    existing = Report.find_by(type: "Reports::#{object.class}", target_id: object.id, user_id: id, deleted: false)
    if existing.nil?
      Report.create(type: "Reports::#{object.class}", target_id: object.id, user_id: id, reason:)
    elsif !reason.nil? && reason.length.positive?
      existing.append_reason(reason)
    end
  end
  # endregion

  def can_export?
    return (Time.zone.now > export_created_at.in(1.week)) && !export_processing unless export_created_at.nil?

    !export_processing
  end

  def inbox_locked? = privacy_lock_inbox
end
