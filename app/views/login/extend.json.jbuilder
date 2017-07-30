if @error
  json.status 'error'
  json.error @error
else
  json.status 'success'
  json.expires @expires
end
