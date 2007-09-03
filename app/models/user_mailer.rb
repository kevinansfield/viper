class UserMailer < ActionMailer::Base
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
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "\"Viper Beta\" <dev@digitalblueprint.co.uk>"
      @subject     = "Viper "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
