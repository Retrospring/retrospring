# frozen_string_literal: true

class UserSerializer < Panko::Serializer
  attributes :id, :type, :name, :url, :summary
  aliases document_context: :@context
  aliases created_at: :published
  aliases screen_name: "preferredUsername"

  has_one :profile_picture, serializer: ImageSerializer, name: :icon
  has_one :profile_header, serializer: ImageSerializer, name: :image

  def document_context = %w[https://www.w3.org/ns/activitystreams]

  def id = context[:controller].activitypub_user_url(object)
  def url = context[:controller].user_url(object)
  def type = "Person"
  def name = object.profile.display_name
  def summary = object.profile.description
end
