class ProfilePictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def paperclip_path
    "users/:attachment/:id_partition/:style/:basename.:extension"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))

    "/images/" + [version_name, "no_avatar.png"].compact.join('/')
  end

  version :original

  version :large do
    process resize_to_fit: [500, 500]
  end
  version :medium do
    process resize_to_fit: [256, 256]
  end
  version :small do
    process resize_to_fit: [80, 80]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
