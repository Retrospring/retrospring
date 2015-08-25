# I seriously hope you guys don't do this.

class Paperclip::FileCommandContentTypeDetector
  alias stupid_type_from_file_command type_from_file_command
  def type_from_file_command
    default = stupid_type_from_file_command
    if default == 'text/x-c' and File.extname(@filename) == '.css'
      'text/css'
    else
      default
    end
  end
end

class ThemeIO < StringIO
  def content_type
    'text/css'
  end

  def original_filename
    'theme.css'
  end
end

class ThemeAdapter < Paperclip::StringioAdapter
  def cache_current_values
    @content_type = 'text/css'
    @original_filename = 'theme.css'
    @size = @target.size
  end

  def extension_for(x)
    'css'
  end
end

Paperclip.io_adapters.register ThemeAdapter do |target|
  ThemeIO === target
end

# Here be monkey patches.
