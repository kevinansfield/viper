class User

  #alias active? activated?
  def activated?
    # the existence of an activation code means they have not activated yet
    state == :active
  end
  
  def change_email_address(new_email_address)
    @change_email  = true
    self.new_email = new_email_address
    self.make_email_activation_code
  end
  
  def activate_new_email
    @activated_email = true
    update_attributes(:email=> self.new_email, :new_email => nil, :email_activation_code => nil)
  end
  
  def recently_changed_email?
    @change_email
  end
  
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end
  
  def reset_password!
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end
  
  def recently_reset_password?
    @reset_password
  end
  
  def recently_forgot_password?
    @forgotten_password
  end
  
  def self.find_for_forgot(email)
    find :first, :conditions => ['email = ? and activation_code IS NULL', email]
  end
  
protected
    
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
    
    def make_email_activation_code
      self.email_activation_code = self.class.make_token
    end
    
    def new_email_entered?
      !self.new_email.blank?
    end
    
    def make_password_reset_code
      self.password_reset_code = self.class.make_token
    end
end