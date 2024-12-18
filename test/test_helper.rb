ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# 引入 DatabaseCleaner 清理数据库
require "database_cleaner/active_record"

# 全局配置 DatabaseCleaner
DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner.clean_with(:truncation) # 清理所有数据
DatabaseCleaner.strategy = :transaction # 使用事务策略加速测试

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # 注意：DatabaseCleaner 默认不支持并行线程，这里需禁用或特殊配置
    # parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # 每个测试前后启动和清理数据库
    setup { DatabaseCleaner.start }
    teardown { DatabaseCleaner.clean }

    # 添加更多的测试辅助方法
    def unique_email
      "user_#{SecureRandom.hex(8)}@example.com"
    end
  end
end
