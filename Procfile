web: bundle exec unicorn_rails -p $PORT -c ./config/unicorn.rb -E $RACK_ENV
worker: bundle exec sidekiq -q default -q mailers
