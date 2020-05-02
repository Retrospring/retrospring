class ProfilePictureUploader < BaseUploader
  def default_url(*args)
    "/images/" + [version_name, "no_avatar.png"].compact.join('/')
  end

  version :large do
    process resize_to_fit: [500, 500]
  end
  version :medium do
    process resize_to_fit: [256, 256]
  end
  version :small do
    process resize_to_fit: [80, 80]
  end
end
