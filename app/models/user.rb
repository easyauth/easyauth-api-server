class User < ApplicationRecord
  validates :email, presence: true
  validates :name, presence: true
  has_secure_password
end
