# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage Rails.configuration.x.uploader_storage

  def default_url
    ActionController::Base.helpers.
      image_path(
        "missing/#{ model.class.to_s.underscore }/" +
        [version_name, "default.png"].compact.join('_'))
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end