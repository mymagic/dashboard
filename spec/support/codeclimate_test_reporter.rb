# Initialize Code Climate for coverage report.
require "codeclimate-test-reporter"

CodeClimate::TestReporter.configure do |config|
  # Do not print info messages.
  config.logger.level = Logger::WARN
end

CodeClimate::TestReporter.start
