# Helper methods for issuing and tracking API keys
module APIKey
  extend ActiveSupport::Concern

  def create_api_key(user)
    require 'securerandom'
    apikey = SecureRandom.hex(32)
    expires = 4.hours.from_now
    redis.set(apikey, user.id)
    redis.expireat(apikey, expires.to_time.to_i)
    [apikey, expires]
  end

  def validate_api_key(key)
    return false unless redis.exists(key)
    redis.get(key)
  end

  def extend_api_key(key)
    return false unless redis.exists(key)
    expires = 4.hours.from_now
    redis.expireat(key, expires.to_time.to_i)
    expires
  end

  private

  def redis
    Redis.current
  end
end
