class ApplicationUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :fog

  def initialize(*)
    super

    @aws_access_key_id     = ENV['aws_access_key'] || 'no_access_key_provided'
    @aws_secret_access_key = ENV['aws_secret_access_key'] || 'no_sak_provided'
    @aws_region            = ENV['aws_region'] || 'no_aws_region_provided'
    self.fog_directory     = ENV['aws_bucket'] || 'no_bucket_name_provided'

    Aws.config.update(
      credentials: Aws::Credentials.new(
        @aws_access_key_id,
        @aws_secret_access_key
      ),
      region: @aws_region
    )

    self.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     @aws_access_key_id,
      aws_secret_access_key: @aws_secret_access_key,
      region: @aws_region
    }
  end

  def s3_bucket
    @s3_bucket ||= Aws::S3::Bucket.new(fog_directory)
  end

  def s3_direct_upload_data
    s3_bucket.presigned_post(
      key:                      "uploads/#{SecureRandom.uuid}/${filename}",
      acl:                      "public-read",
      success_action_status:    "201",
      metadata:                 { "original-filename" => "${filename}" },
      content_disposition:      "inline;filename=${filename}",
      content_type_starts_with: "image/"
    )
  end

  # Updates model with original file location inside S3 and creates
  # required image versions in background process.
  #
  # @param String s3_key S3 Presigned Post URL with path of an uploaded image.
  # Consists of: "#{store_dir}/#{uuid}/#{original_filename}"
  #
  # @param Symbol promise_display_style The style of an image URL to return
  #
  # @return String the URL of future image.
  def process_and_upload_to_s3(s3_key:, promise_display_style:)
    s3_path = s3_key.sub(%r{^#{store_dir}/}, '')
    # Remove old files from S3 and use new one instead
    model.send("remove_#{mounted_as}!")
    model.update_column(mounted_as, s3_path)
    # Recreate all versions
    CarrierwaveProcessingJob.perform_later(model, mounted_as.to_s)
    # Can't use `url(promise_display_style)` because images are not
    # processed yet, so have to built from parts.
    [
      s3_bucket.url,
      store_dir,
      version_path(path: s3_path, style: promise_display_style)
    ].join('/')
  end

  def store_dir
    "uploads"
  end

  def version_path(path:, style:)
    original_filename = File.basename(path)
    hashed_name = "#{Digest::MD5.hexdigest(path)[0..7]}"\
                  "#{File.extname(original_filename)}"
    path.gsub(original_filename, "#{style}_#{hashed_name}")
  end
end
