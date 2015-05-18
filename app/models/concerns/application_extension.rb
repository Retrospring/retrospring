module Concerns::ApplicationExtension
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, class_name: 'User'

    has_attached_file :icon, styles: { normal: "100x100#" },
                      default_url: "/images/app_icon/:style/no_icon.png", use_timestamp: false,
                      processors: [:cropper]
    validates_attachment_content_type :icon, :content_type => /\Aimage\/(png|jpe?g|gif)\Z/
    process_in_background :icon
  end
end
