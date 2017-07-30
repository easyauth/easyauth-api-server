if !Rails.application.secrets.redis_path.nil?
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(path: Rails.application.secrets.redis_path))
else
  if defined? Rails.application.secrets.redis_pass
  	password = Rails.application.secrets.redis_pass
  else
  	password = nil
  end
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(
    host: Rails.application.secrets.redis_host,
    port: Rails.application.secrets.redis_port,
    db: Rails.application.secrets.redis_db,
    password: password
  ))
end
