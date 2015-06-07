module Concerns::ApplicationExtension
  extend ActiveSupport::Concern

  included do
    # causes issues
    # belongs_to :owner, class_name: 'User'

    has_attached_file :icon, styles: { normal: "128x128#" },
                      default_url: "/images/app_icon/:style/no_icon.png", use_timestamp: false,
                      processors: [:cropper]
    validates_attachment_content_type :icon, :content_type => /\Aimage\/(png|jpe?g|gif)\Z/
    process_in_background :icon

    validates :name, exclusion: { in: %w(Web) }, length: { minimum: 3 }

    before_save do
      self.homepage = if homepage.match %r{\Ahttps?://}
                       homepage
                     else
                       "http://#{homepage}"
                     end unless homepage.blank? or homepage.empty?

      # if self.deleted
      #   self.destroy_associations
      # end
    end
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
end
