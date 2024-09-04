# frozen_string_literal: true

class User < ApplicationRecord
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

  has_many :totp_recovery_codes, dependent: :destroy_async

  has_one :profile, dependent: :destroy

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

  after_destroy do
    Retrospring::Metrics::USERS_DESTROYED.increment
  end

  after_create do
    Profile.create(user_id: id) if Profile.where(user_id: id).count.zero?

    Retrospring::Metrics::USERS_CREATED.increment
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

  # @return [Boolean] is the user a moderator?
  def mod? = has_cached_role?(:moderator) || has_cached_role?(:administrator)

  def admin? = has_cached_role?(:administrator)
end
