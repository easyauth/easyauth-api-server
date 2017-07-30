if @error
  json.status 'error'
  json.error @error
else
  json.status 'success'
  json.apikey @apikey
  json.expires @expires
end
