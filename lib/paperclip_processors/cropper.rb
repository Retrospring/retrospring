COLORS = 64.freeze

module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      @auto_orient = false
      if crop_command
        x = super
        i = x.index '-crop'
        2.times { x.delete_at i } if i
        i = x.index '-layers'
        2.times { x.delete_at i } if i
        crop_command + x
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if target.cropping?
        cmd = if animated?
          ['-coalesce', '-repage', '0x0']
        else
          []
        end

        cmd.push '-crop'

        case @attachment.name
        when :profile_picture
          cmd.push "'#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}'"
        when :profile_header
          cmd.push "'#{target.crop_h_w.to_i}x#{target.crop_h_h.to_i}+#{target.crop_h_x.to_i}+#{target.crop_h_y.to_i}'"
        else
          return nil
        end

        # optimize
        cmd.push(%W(+repage -coalesce -layers optimize +dither -deconstruct -depth 8 \\( -clone 0--1 -background none +append -quantize transparent -colors #{COLORS} -unique-colors -write mpr:cmap +delete \\) -map mpr:cmap)).flatten! if animated?

        cmd
      end
    end
  end
end
