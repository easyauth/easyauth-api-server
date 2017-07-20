if defined? Rails.application.secrets.redis_path
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(path: Rails.application.secrets.redis_path))
else
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(
    host: Rails.application.secrets.redis_host,
    port: Rails.application.secrets.redis_port,
    db: Rails.application.secrets.redis_db,
    password: Rails.application.secrets.redis_pass
  ))
end
