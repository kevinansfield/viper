class UserMailer < ActionMailer::Base
  
  helper :application
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "#{HOST}/user/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{HOST}"
  end
  
  def change_email(user)
    setup_email(user)
    @recipients  = "#{user.new_email}" 
    @subject    += 'Request to change your email'
    @body[:url]  = "#{HOST}/user/activate_new_email/#{user.email_activation_code}" 
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = "#{HOST}/user/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset'
  end
  
  def friend_request(mail)
    setup_email(mail[:user])
    @subject     = "New friend request at #{SITENAME}"
    @recipients  = mail[:friend].email
    @body        = mail
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "\"#{SITENAME}\" <#{VIPER_EMAIL}>"
      @subject     = "#{SITENAME} "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
