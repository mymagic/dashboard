class LogoUploader < ApplicationUploader
  version :thumb do
    process resize_to_fit: [200, 200]
    process convert: :png
  end

  version :icon do
    process resize_to_fit: [20, 20]
    process convert: :png
  end
end
