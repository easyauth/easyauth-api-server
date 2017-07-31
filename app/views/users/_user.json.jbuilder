json.extract! user, :id, :name, :email, :admin, :validated
json.url user_url(user, format: :json)
