ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# 引入 DatabaseCleaner 清理数据库
require "database_cleaner/active_record"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # DatabaseCleaner 配置
    setup do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
    end

    # 避免多次加载数据库清理器
    at_exit { DatabaseCleaner.clean_with(:truncation) }

    # 添加更多的测试辅助方法
    def unique_email
      "user_#{SecureRandom.hex(4)}@example.com"
    end
  end
end
