source 'https://rubygems.org'

ruby '2.2.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Bootstrap for views
gem 'bootstrap-sass', github: 'twbs/bootstrap-sass', tag: 'v3.3.3'

# Use simple_form for forms
gem 'simple_form'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Dynamic nested forms using jQuery made easy
gem 'cocoon'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use Postgres as database
gem 'pg'

# Use Devise for authentication
gem 'devise'
gem 'devise_invitable'

# Use CanCanCan for authorization
gem 'cancancan', '~> 1.10'

# Use MiniMagick for photo processing
gem 'mini_magick'

# Use Carrierwave for uploaders
gem 'carrierwave'

# Use ranked-model for sortable lists
gem 'ranked-model'

# Create pretty URL’s and work with human-friendly strings as if they were numeric ids for ActiveRecord models
gem 'friendly_id'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # pry as a better ruby command line
  gem 'pry-rails'
  gem 'awesome_print'

  # guard to auto-run specs
  gem 'guard-rspec'
end

group :test do
  # Use DatabaseCleaner
  gem 'database_cleaner'

  # Use RSPEC for testing framework
  gem 'rspec-rails'

  # FactoryGirl as a fixtures replacement
  gem 'factory_girl_rails'

  # Shoulda matchers to check validations in rspec
  gem 'shoulda-matchers', require: false

  # Capybara
  gem 'capybara'

  # Email spec
  gem 'capybara-email'
end

group :production, :staging do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'rack-timeout'
  gem 'unicorn'
  gem 'sentry-raven'
end
