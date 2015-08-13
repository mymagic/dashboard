redis: redis-server
search: elasticsearch
mail: mailcatcher -f
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q default -q mailers
