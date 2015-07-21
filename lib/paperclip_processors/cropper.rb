module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        x = super
        i = x.index '-crop'
        2.times { x.delete_at i } if i
        crop_command + x
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if target.cropping?
        case @attachment.name
        when :icon
        when :profile_picture
          ['-auto-orient', '-strip', '+repage', '-crop', "'#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}'"]
        when :profile_header
          ['-auto-orient', '-strip', '+repage', '-crop', "'#{target.crop_h_w.to_i}x#{target.crop_h_h.to_i}+#{target.crop_h_x.to_i}+#{target.crop_h_y.to_i}'"]
        end
      end
    end
  end
end
