class AvatarUploader < ApplicationUploader
  version :thumb do
    process resize_to_fill: [200, 200]
  end

  version :small_thumb do
    process resize_to_fill: [60, 60]
  end

  version :icon do
    process resize_to_fill: [20, 20]
  end
end
