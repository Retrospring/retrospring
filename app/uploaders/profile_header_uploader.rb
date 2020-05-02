class ProfileHeaderUploader < BaseUploader
  def default_url(*args)
    "/images/header/" + [version_name, "no_header.jpg"].compact.join('/')
  end

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
