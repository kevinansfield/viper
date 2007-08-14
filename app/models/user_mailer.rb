class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://localhost:3009/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://localhost:3009/"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "dev@digitalblueprint.co.uk"
      @subject     = "Viper "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
