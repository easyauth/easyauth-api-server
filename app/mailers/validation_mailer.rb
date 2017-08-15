# Send emails to new users
class ValidationMailer < ApplicationMailer
  def welcome_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Welcome to Easyauth!'
    )
  end

  def update_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Easyauth: Please confirm your new email address'
    )
  end

  def goodbye_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Easyauth: Please confirm you wish to delete your account'
    )
  end

  def api_welcome_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Your new Easyauth API account'
    )
  end

  def api_update_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Easyauth API: Please confirm your new email address'
    )
  end

  def api_goodbye_email(user, email_validation)
    @user = user
    @code = email_validation.code
    mail(
      to: @user.email,
      subject: 'Easyauth: Please confirm you wish to delete your account'
    )
  end
end
