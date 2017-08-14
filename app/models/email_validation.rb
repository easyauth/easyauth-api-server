# Store validation codes for emails, etc
class EmailValidation < ApplicationRecord
  belongs_to :user
  validates_email_format_of :new_email, allow_blank: true

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
    mailer = case type
             when EmailValidationsTypes::CREATE
              ValidationMailer.welcome_email(user, validation)
             when EmailValidationsTypes::CHANGE
              ValidationMailer.update_email(user, validation)
             when EmailValidationsTypes::DELETE
              ValidationMailer.goodbye_email(user, validation)
    ValidationMailer.welcome_email(user, validation).deliver
  end
end

module EmailValidationsTypes
  CREATE = 1
  CHANGE = 2
  DELETE = 3
  API_CREATE = 4
  API_DELETE = 5
end
