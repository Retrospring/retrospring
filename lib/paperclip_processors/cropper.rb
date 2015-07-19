COLORS = 32.freeze

module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      @auto_orient = false
      if crop_command
        x = super
        i = x.index '-crop'
        2.times { x.delete_at i } if i
        crop_command + x
      else
        super
      end
    end

    def gifsicle_command
      %W(-k#{COLORS} -U -w -f -O3 --same-delay -l --no-comments --no-names --no-extensions -D asis --resize-method mix)
    end

    def resize_command
      w = [0, @target_geometry.width.to_i].max
      h = [0, @target_geometry.height.to_i].max


      if w > 0 and h == 0
        %W(--resize-width #{w})
      elsif w == 0 and h > 0
        %W(--resize-height #{h})
      else
        %W(--resize #{w}x#{h})
      end
    end

    def gifsicle(arguments = "", local_options = {})
      Paperclip.run('gifsicle', arguments, local_options)
    end

    def make
      if animated?
        src = @file
        dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
        dst.binmode

        begin
          parameters = []

          parameters << gifsicle_command
          parameters << gifscile_crop_command
          parameters << resize_command

          parameters << "-o"
          parameters << ":dest"
          parameters << ":source"


          parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

          success = gifsicle(parameters, :source => "#{File.expand_path(src.path)}#{'[0]' unless animated?}", :dest => File.expand_path(dst.path))
        rescue Cocaine::ExitStatusError => e
          raise Paperclip::Error, "There was an error processing the thumbnail for #{@basename}" if @whiny
        rescue Cocaine::CommandNotFoundError => e
          raise Paperclip::Errors::CommandNotFoundError.new("Could not run the `gifsicle` command. Please install Gifsicle.")
        end

        dst
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if target.cropping?
        case @attachment.name
        when :profile_picture
          ['-crop', "#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}"]
        when :profile_header
          ['-crop', "#{target.crop_h_w.to_i}x#{target.crop_h_h.to_i}+#{target.crop_h_x.to_i}+#{target.crop_h_y.to_i}"]
        end
      end
    end

    def gifscile_crop_command
      target = @attachment.instance
      if target.cropping?
        case @attachment.name
        when :profile_picture
          ['--crop', "#{target.crop_x.to_i},#{target.crop_y.to_i}+#{target.crop_w.to_i}x#{target.crop_h.to_i}"]
        when :profile_header
          ['--crop', "#{target.crop_h_x.to_i},#{target.crop_h_y.to_i}+#{target.crop_h_w.to_i}x#{target.crop_h_h.to_i}"]
        end
      end
    end
  end
end
