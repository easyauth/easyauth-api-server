json.extract! certificate, :serial, :active, :valid_until
json.user user_url(certificate.user)
json.url certificate_url(certificate, format: :json)
json.download certificate_url(certificate, format: :pem)
