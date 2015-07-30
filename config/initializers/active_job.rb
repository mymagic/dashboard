unless Rails.env.test?
  # Set Sidekiq as ActiveJob adapter
  ActiveJob::Base.queue_adapter = :sidekiq
end
