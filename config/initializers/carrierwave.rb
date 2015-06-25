CarrierWave.configure do |config|
  config.fog_attributes = { 'Cache-Control': "max-age=#{ 365.day.to_i }" } # optional, defaults to {}
end
