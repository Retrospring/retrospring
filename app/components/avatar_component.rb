# frozen_string_literal: true

class AvatarComponent < ViewComponent::Base
  ALLOWED_SIZES = %w[xs sm md lg xl xxl].freeze

  def initialize(user:, size:, classes: [])
    @user = user
    @size = size if ALLOWED_SIZES.include? size
    @classes = classes
  end

  private

  def size_to_version(size)
    case size
    when "xs", "sm"
      :small
    when "md", "lg"
      :medium
    when "xl", "xxl"
      :large
    end
  end

  def alt_text = "@#{@user.screen_name}"

  def avatar_classes = @classes.unshift("avatar-#{@size}")

  def avatar_image = @user.profile_picture.url(size_to_version(@size))
end
