# Preview all emails at http://localhost:3000/rails/mailers/new_user_mailer
class NewUserMailerPreview < ActionMailer::Preview
  def sample_mail_preview
    user = User.readonly.first
    email_validation = EmailValidation.new(code: 'abc123', user: user)
    NewUserMailer.welcome_email(user, email_validation)
  end
end
