class User < ApplicationRecord
  validates :email, presence: true
  validates_email_format_of :email
  validates :name, presence: true
  has_secure_password
end
