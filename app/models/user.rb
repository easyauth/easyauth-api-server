class User < ApplicationRecord
  validates :email_address, presence: true
  validates :name, presence: true
  has_secure_password
end
