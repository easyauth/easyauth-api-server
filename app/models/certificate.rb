# Validate new certificate entries
class CertificateValidator < ActiveModel::Validator
  def validate(record)
    if User.joins(:certificates)
           .where(certificates: { active: true, user: record.user })
      record.errors[:user] << 'User can only have one active certificate!'
    end
  end
end

# Certificate model
class Certificate < ApplicationRecord
  self.primary_key = 'serial'
  belongs_to :user
end
