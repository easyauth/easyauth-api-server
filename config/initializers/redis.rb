if !Rails.application.secrets.redis_path.nil?
  puts 'Using path'
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(path: Rails.application.secrets.redis_path))
else
  puts 'Not using path'
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(
    host: Rails.application.secrets.redis_host,
    port: Rails.application.secrets.redis_port,
    db: Rails.application.secrets.redis_db,
    password: Rails.application.secrets.redis_pass
  ))
end
