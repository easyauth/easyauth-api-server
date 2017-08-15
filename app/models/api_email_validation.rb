class ApiEmailValidation < ApplicationRecord
  belongs_to :api_key_user

  def self.generate(user, type, new_email = nil)
    require 'securerandom'
    code = SecureRandom.hex(8)
    validation = ApiEmailValidation.new(
      api_key_user: user,
      code: code,
      action: type,
      new_email: new_email
    )
    validation.save
    mailer = case type
             when EmailValidationsTypes::API_CREATE
               ValidationMailer.api_welcome_email(user, validation)
             when EmailValidationsTypes::API_CHANGE
               ValidationMailer.api_update_email(user, validation)
             when EmailValidationsTypes::API_DELETE
               ValidationMailer.api_goodbye_email(user, validation)
             end
    mailer.deliver
  end
end
