require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false

  config.action_controller.perform_caching = true

  config.public_file_server.enabled = false

  config.assets.compile = false

  config.active_storage.service = :local

  config.force_ssl = false

  config.logger = ActiveSupport::Logger.new("log/production.log", 1, 50.megabytes)
    .tap { |logger| logger.formatter = ::Logger::Formatter.new }
  config.log_tags = [ :request_id ]

  config.log_level = :debug

  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = true

  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  config.hosts << "184.72.132.98"
  config.hosts << "127.0.0.1"
  config.hosts << "localhost"
end
