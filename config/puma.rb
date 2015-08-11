# Config taken from:
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#config
workers Integer(ENV['WEB_CONCURRENCY'] || 2)

# If your app is not thread safe, you will only be able to use workers.
# Set your min and max threads to 1:
# $ heroku config:set MAX_THREADS=1
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # In Rails 4.1+ you can use database.yml to set your connection pool size.
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
