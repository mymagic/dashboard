RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :deletion
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do |example|
    if example.metadata[:elasticsearch].present?
      DatabaseCleaner.strategy = :truncation
    end

    DatabaseCleaner.start
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean

    if example.metadata[:elasticsearch].present?
      DatabaseCleaner.strategy = :transaction
    end
  end
end
