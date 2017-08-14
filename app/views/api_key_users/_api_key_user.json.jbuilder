json.extract! user, :id, :email, :validated, :public_key, :secret_key
json.url api_key_user_url(user, format: :json)
