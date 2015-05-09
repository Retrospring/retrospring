Paperclip::Attachment.default_options[:storage] = :fog
Paperclip::Attachment.default_options[:fog_credentials] = {:provider => "Local", :local_root => "#{Rails.root}/public"}
Paperclip::Attachment.default_options[:fog_directory] = "/system"
Paperclip::Attachment.default_options[:fog_host] = "/system"

unless APP_CONFIG["fog"].nil?
  Paperclip::Attachment.default_options[:fog_credentials] = APP_CONFIG["fog"]["credentials"] unless APP_CONFIG["fog"]["credentials"].nil?
  Paperclip::Attachment.default_options[:fog_directory] = APP_CONFIG["fog"]["directory"] unless APP_CONFIG["fog"]["directory"].nil?
  Paperclip::Attachment.default_options[:fog_host] = APP_CONFIG["fog"]["host"] unless APP_CONFIG["fog"]["host"].nil?

  if not APP_CONFIG["fog"]["credentials"].nil? and APP_CONFIG["fog"]["host"].nil?
    Paperclip::Attachment.default_options[:fog_host] = nil
  end
end
