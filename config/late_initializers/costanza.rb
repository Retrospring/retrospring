# I seriously hope you guys don't do this.

class Paperclip::FileCommandContentTypeDetector
  alias old_type_from_file_command type_from_file_command
  def type_from_file_command
    default = old_type_from_file_command
    if default.strip == 'text/x-c' or default.strip == 'text/plain' or default.strip == 'text/stylesheet'
      'text/css'
    else
      default
    end
  end
end

# Here be monkey patches.
