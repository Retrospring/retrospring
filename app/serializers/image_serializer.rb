# frozen_string_literal: true

class ImageSerializer < Panko::Serializer
  attributes :type, :url, :mime
  aliases mime: "mediaType"

  def type = "Image"
  def mime = object.content_type
  def url = object.url
end
