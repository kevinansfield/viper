require 'digest/sha1'
class User
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  validates_format_of       :login,
                            :with => /^[A-Z0-9_]*$/i,
                            :message => "must contain only letters, numbers, and underscores"
                            
  validates_format_of       :email,
                            :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
                            :message => "must be a valid email address"
                            
  validates_length_of       :new_email, 
                            :within => 6..100, 
                            :if => :new_email_entered?
  validates_format_of       :new_email,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/,
                            :if => :new_email_entered?
  
  before_save :downcase_email_and_login
  before_save :encrypt_password
  before_create :make_activation_code
  before_create :set_first_user_as_admin
  
  # Assures that updated email addresses do not conflict with existing emails
  def validate
    if User.find_by_email(new_email)
      errors.add(new_email, "is already being used")
    end
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def set_first_user_as_admin
    self.admin = true if User.count.zero?
  end
  
  def downcase_email_and_login
    login.downcase!
    email.downcase!
  end
end