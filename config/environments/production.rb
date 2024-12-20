require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 禁止代码重新加载
  config.enable_reloading = false

  # 在启动时预加载代码
  config.eager_load = true

  # 禁用详细错误报告
  config.consider_all_requests_local = false

  # 启用缓存
  config.action_controller.perform_caching = true

  # 禁用 public 文件夹下的静态文件服务（由 NGINX/Apache 提供）
  config.public_file_server.enabled = false

  # 禁用 assets pipeline 回退（必须预编译）
  config.assets.compile = false

  # 设置 ActiveStorage 存储服务
  config.active_storage.service = :local

  # 强制 HTTPS（如果你需要启用 SSL 支持）
  config.force_ssl = false

  # 日志配置：写入 production.log
  config.logger = ActiveSupport::Logger.new("log/production.log", 1, 50.megabytes)
    .tap { |logger| logger.formatter = ::Logger::Formatter.new }
  config.log_tags = [ :request_id ]

  # 设置日志级别为 debug，便于排查问题
  config.log_level = :debug

  # ActionMailer 配置
  config.action_mailer.perform_caching = false

  # 启用 I18n 回退到默认语言
  config.i18n.fallbacks = true

  # 禁用 ActiveSupport 中的弃用警告
  config.active_support.report_deprecations = false

  # 禁止在迁移后导出数据库模式
  config.active_record.dump_schema_after_migration = false

  # 仅在 attributes_for_inspect 中显示 :id
  config.active_record.attributes_for_inspect = [ :id ]

  # 配置允许的主机
  config.hosts << "34.205.71.29"
  config.hosts << "127.0.0.1"
  config.hosts << "localhost"
end
