CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     ENV['aws_access_key'],        # required
    aws_secret_access_key: ENV['aws_secret_access_key'], # required
    region:                ENV['aws_region']   # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['aws_bucket']    # required
  config.fog_attributes = { 'Cache-Control': "max-age=#{ 365.day.to_i }" } # optional, defaults to {}
end
