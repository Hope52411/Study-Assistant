# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require 'capybara/rspec'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rails'

# Ensure that migrations are up to date before running tests
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

require 'database_cleaner/active_record'

RSpec.configure do |config|
  # Include Devise test helpers for integration and request tests
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Include FactoryBot syntax methods (e.g., `create`, `build`)
  config.include FactoryBot::Syntax::Methods

  # Use transactional fixtures for tests
  config.use_transactional_fixtures = true

  # Automatically infer spec types from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails gem backtraces in test output
  config.filter_rails_from_backtrace!

  # Include files from `spec/support` folder
  Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

  # Capybara configuration for system tests
  config.before(:each, type: :system) do
    driven_by(:selenium_chrome_headless) # Headless Chrome for system tests
  end

  # DatabaseCleaner configuration
  config.before(:suite) do
    User.delete_all
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
