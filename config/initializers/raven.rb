if Rails.env.production? || Rails.env.staging?
  Raven.configure do |c|
    c.server_name = ENV['SENTRY_SERVER_NAME'] if ENV['SENTRY_SERVER_NAME']
  end
end
