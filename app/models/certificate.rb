# Validate new certificate entries
class CertificateValidator < ActiveModel::Validator
  def validate(record)
    if User.joins(:certificates)
           .where(certificates: { valid: true, user: record.user })
      record.errors[:user] << 'User can only have one valid certificate!'
    end
  end
end

# Certificate model
class Certificate < ApplicationRecord
  self.primary_key = 'serial'
  belongs_to :user
end
