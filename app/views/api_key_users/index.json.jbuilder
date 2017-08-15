json.status 'success'
json.users do
  json.array! @users, partial: 'api_key_users/api_key_user', as: :user
end