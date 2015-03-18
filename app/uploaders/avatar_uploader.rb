# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def default_url
    ActionController::Base.helpers.image_path("missing/#{ model.class.to_s.underscore }/" + [version_name, "default.png"].compact.join('_'))
  end

  version :thumb do
    process resize_to_fill: [200, 200]
  end

  version :icon do
    process resize_to_fill: [20, 20]
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
