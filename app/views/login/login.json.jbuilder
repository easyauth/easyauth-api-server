if @error
  json.status 'error'
  json.error @error
else
  json.status 'success'
  json.apikey @apikey
  json.expires @expires
  json.user user_url @user
end
