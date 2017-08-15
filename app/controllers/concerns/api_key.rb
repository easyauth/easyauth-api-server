# Helper methods for issuing and tracking API keys
module APIKey
  extend ActiveSupport::Concern

  def create_api_key(user)
    require 'securerandom'
    require 'json'
    apikey = SecureRandom.hex(32)
    expires = 4.hours.from_now
    redis.set(apikey, {type: user.class.to_s, id: user.id}.to_json)
    redis.expireat(apikey, expires.to_time.to_i)
    [apikey, expires]
  end

  def validate_api_key(key)
    return false unless redis.exists(key)
    value = JSON.parse(redis.get(key), symbolize_names: true)
    if value[:type] == "User"
      return false unless User.exists?(value[:id])
      User.find(value[:id])
    elsif value[:type] == "ApiKeyUser"
      return false unless ApiKeyUser.exists?(value[:id])
      ApiKeyUser.find(value[:id])
    end
  end

  def extend_api_key(key)
    return false unless redis.exists(key)
    expires = 4.hours.from_now
    redis.expireat(key, expires.to_time.to_i)
    expires
  end

  def delete_api_key(key)
    redis.del(key)
  end

  private

  def redis
    Redis.current
  end
end
