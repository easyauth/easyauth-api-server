if @error
  json.status 'error'
  json.error @error
else
  json.status 'success'
  json.apikey @apikey
  json.expires @expires
  json.authenticated_as_id @user.id
  json.user api_key_user_url @user
end
