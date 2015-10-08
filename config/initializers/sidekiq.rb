Sidekiq.configure_client do |config|
  config.redis = { size: 3, url: ENV["REDIS_URL"] }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 3
  end
end
