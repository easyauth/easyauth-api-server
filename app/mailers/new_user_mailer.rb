# Send emails to new users
class NewUserMailer < ApplicationMailer
  def welcome_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Welcome to Easyauth!'
    )
  end
end
