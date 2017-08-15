class ApiKeyUser < ApplicationRecord
  validates :email, presence: true
  validates_email_format_of :email
  has_secure_password
end
