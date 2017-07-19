# Session store configuration

Rails.application.config.session_store :redis_store, {
  servers: [
    {
      host: 'localhost',
      port: 6379,
      db: 0,
      password: 'secret', # Change this to something random
      namespace: 'cache'
    }
  ],
  expire_after: 90.minutes,
  key: 'secret' # Change this, ensure it's the same as frontend
}
