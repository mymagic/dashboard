# encoding: utf-8

class LogoUploader < BaseUploader
  version :thumb do
    process resize_to_fit: [200, 200]
    process convert: :png

    def full_filename(for_file = model.logo.file)
      version_path(path: model[:logo], style: :thumb)
    end
  end

  version :icon do
    process resize_to_fit: [20, 20]
    process convert: :png

    def full_filename(for_file = model.logo.file)
      version_path(path: model[:logo], style: :icon)
    end
  end
end
