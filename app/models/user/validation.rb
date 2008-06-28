require 'digest/sha1'

class User
  validates_presence_of     :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_format_of       :login, :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD 
  
  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
                            
  validates_length_of       :new_email, 
                            :within => 6..100, 
                            :if => :new_email_entered?
  validates_format_of       :new_email,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/,
                            :if => :new_email_entered?
  
  before_save :downcase_email_and_login
  before_create :make_activation_code
  before_create :set_first_user_as_admin
  
  # Assures that updated email addresses do not conflict with existing emails
  def validate
    if User.find_by_email(new_email)
      errors.add(new_email, "is already being used")
    end
  end
  
protected  
  def set_first_user_as_admin
    self.admin = true if User.count.zero?
  end
  
  def downcase_email_and_login
    login.downcase!
    email.downcase!
  end
end