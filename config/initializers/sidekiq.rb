Sidekiq.configure_client do |config|
  config.redis = {
    size: (ENV['REDIS_CLIENT_SIZE'] || 3).to_i.freeze,
    url: ENV["REDIS_URL"]
  }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 3
  end
end
