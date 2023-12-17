class ProfileHeaderUploader < BaseUploader
  def default_url(*args) = "/images/header/#{[version_name || args.first, 'no_header.jpg'].compact.join('/')}"

  def size_range = (1.byte)..(10.megabytes)

  version :web do
    process resize_to_fit: [1500, 350]
  end
  version :mobile do
    process resize_to_fit: [450, 105]
  end
  version :retina do
    process resize_to_fit: [900, 210]
  end
end
