if !Settings.redis.path.nil?
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(path: Settings.redis.path))
else
  puts "Rails environment: #{Rails.env}"
  puts "db password: #{Settings.db.pass}"
  puts "redis host: #{Settings.redis.host}"
  puts "redis password: #{Settings.redis.password}"
  Redis.current = Redis::Namespace.new('easyauth', redis: Redis.new(
    host: Settings.redis.host,
    port: Settings.redis.port,
    db: Settings.redis.db,
    password: Settings.redis.password
  ))
end
