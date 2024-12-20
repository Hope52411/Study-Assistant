ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
end

require "database_cleaner/active_record"


DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner.clean_with(:truncation)
DatabaseCleaner.strategy = :transaction

module ActiveSupport
  class TestCase
    fixtures :all

    setup { DatabaseCleaner.start }
    teardown { DatabaseCleaner.clean }

    def unique_email
      "user_#{SecureRandom.hex(8)}@example.com"
    end
  end
end
