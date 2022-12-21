class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip
  include CarrierWave::MiniMagick
  include CarrierWave::Backgrounder::Delay

  storage :fog

  # Store original size
  version :original

  # Process cropping on upload
  process :cropping

  def store_dir
    "/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def paperclip_path
    return "/users/:attachment/:id_partition/:style/:basename.:extension" if APP_CONFIG["fog"].blank?

    "users/:attachment/:id_partition/:style/:basename.:extension"
  end

  def cropping
    x = model.public_send("#{mounted_as}_x")
    y = model.public_send("#{mounted_as}_y")
    w = model.public_send("#{mounted_as}_w")
    h = model.public_send("#{mounted_as}_h")

    manipulate! do |image|
      image.crop "#{w}x#{h}+#{x}+#{y}"
    end
  end
end
