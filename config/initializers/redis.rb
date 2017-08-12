if !Settings.redis.path.nil?
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(path: Settings.redis.path))
else
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(
    host: Settings.redis.host,
    port: Settings.redis.port,
    db: Settings.redis.db,
    password: Settings.redis.password
  ))
end
