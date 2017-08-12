json.extract! user, :id, :name, :email, :admin, :validated
json.certificate @certificate
json.url user_url(user, format: :json)
