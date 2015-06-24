# encoding: utf-8

class AvatarUploader < BaseUploader
  version :thumb do
    process resize_to_fill: [200, 200]

    def full_filename(for_file = model.avatar.file)
      version_path(path: model[:avatar], style: :thumb)
    end
  end

  version :small_thumb do
    process resize_to_fill: [60, 60]

    def full_filename(for_file = model.avatar.file)
      version_path(path: model[:avatar], style: :small_thumb)
    end
  end

  version :icon do
    process resize_to_fill: [20, 20]

    def full_filename(for_file = model.avatar.file)
      version_path(path: model[:avatar], style: :icon)
    end
  end
end
