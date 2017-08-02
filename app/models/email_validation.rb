# Store validation codes for emails, etc
class EmailValidation < ApplicationRecord
  belongs_to :user

  def self.generate(user, type, new_email = nil)
    require 'securerandom'
    code = SecureRandom.hex(8)
    validation = EmailValidation.new(
      user: user,
      code: code,
      action: type,
      new_email: new_email
    )
    validation.save
    NewUserMailer.welcome_email(user, validation)
  end
end

module EmailValidationsTypes
  CREATE = 1
  CHANGE = 2
  DELETE = 3
end
