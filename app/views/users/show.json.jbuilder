json.status 'success'
json.user do 
	json.partial! "users/user", user: @user
end
