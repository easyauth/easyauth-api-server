json.extract! user, :id, :name, :email, :admin, :validated
json.certificate_id @certificate_id
json.certificate_url @certificate_url
json.url user_url(user, format: :json)
