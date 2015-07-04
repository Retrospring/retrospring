# https://github.com/intridea/grape/wiki/Uploaded-file-and-paperclip
module Paperclip
  class HashieMashUploadedFileAdapter < AbstractAdapter
    attr_accessor :original_filename

    def initialize(target)
      @tempfile, @content_type, @size = target.tempfile, target.type, target.tempfile.size
      self.original_filename = target.filename
    end

  end
end

Paperclip.io_adapters.register Paperclip::HashieMashUploadedFileAdapter do |target|
  target.is_a? Hashie::Mash
end
