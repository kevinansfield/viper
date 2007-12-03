require 'digest/sha1'
class User < ActiveRecord::Base
  has_one  :profile
  has_one  :avatar
  has_one  :bio
  has_one  :blog
  has_one  :wall
  
  has_many :comments
  has_many :news
  has_many :articles
  
  has_many :friendships
  has_many :friends,            :through => :friendships, :conditions => "status = 'accepted'"
  has_many :requested_friends,  :through => :friendships, :source => :friend, :conditions => "status = 'requested'"
  has_many :pending_friends,    :through => :friendships, :source => :friend, :conditions => "status = 'pending'"
           
  has_many :messages_as_sender,   :foreign_key => 'sender_id',    :class_name => 'Message', :order => 'created_at DESC'
  has_many :messages_as_receiver, :foreign_key => 'receiver_id',  :class_name => 'Message', :order => 'created_at DESC'
  has_many :unread_messages,      :foreign_key => 'receiver_id',  :class_name => 'Message', :conditions => 'read_at IS NULL', :order => 'created_at DESC'
  has_many :read_messages,        :foreign_key => 'receiver_id',  :class_name => 'Message', :conditions => 'read_at IS NOT NULL', :order => 'created_at DESC'
           
  has_permalink :login
  
  acts_as_ferret :fields => ['login', 'email'], :remote => false
  
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
                      
  before_save :encrypt_password
  before_create :make_activation_code 
  
  def to_param
    permalink
  end
  
  def admin?
    self.activated? && self.admin
  end
  
  # Assures that updated email addresses do not conflict with existing emails
  def validate
    if User.find_by_email(new_email)
      errors.add(new_email, "is already being used")
    end
  end
  
  # Activates the user in the database.
  def activate
    @activated = true
    self.attributes = {:activated_at => Time.now.utc, :activation_code => nil}
    save(false)
  end

  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ?', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
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

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
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
  
  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
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
  
  def hit!
    self.hits += 1
    self.save!
  end
  
  def views() hits end
  
  def setup_for_display!
    self.profile ||= Profile.new
    self.avatar ||= nil
    self.bio ||= Bio.new
    self.blog ||= Blog.new
  end
  
  def full_name
    self.profile ||= Profile.new
    self.profile.full_name || self.login
  end
  
  def first_name
    self.profile ||= Profile.new
    self.profile.first_name.blank? ? self.login : self.profile.first_name
  end
  
  def last_name
    self.profile ||= Profile.new
    self.profile.last_name.blank? ? self.login : self.profile.last_name
  end
  
  def self.find_latest(number = 5)
    find :all, :conditions => ['activation_code IS NULL'], :limit => number, :order => 'created_at DESC'
  end
  
  def self.find_all_for_news_delivery
    find :all
  end
  
  # Alias for all received messages
  def received_messages
    self.messages_as_receiver
  end
  
  # Alias for all sent messages
  def sent_messages
    self.messages_as_sender
  end
  
  # Alias for unread messages
  def new_messages
    self.unread_messages
  end

  # Alias for read messages
  def old_messages
    self.read_messages
  end

  # Accepts a message object and flags the message as deleted by sender
  def delete_from_sent(message)
    if message.sender_id == self.id
      message.update_attribute :sender_deleted, true
      return true
    else
      return false
    end
  end

  # Accepts a message object and flags the message as deleted by the sender
  def delete_from_received(message)
    if message.receiver_id == self.id
      message.update_attribute :receiver_deleted, true
      return true
    else
      return false
    end
  end

  # Accepts a user object as the receiver, and a message
  # and creates a message relationship joining the two users
  def send_message(receiver, message)
    Message.create!(:sender => self, :receiver => receiver, :subject => message.subject, :body => message.body)
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
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def make_email_activation_code
      self.email_activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def new_email_entered?
      !self.new_email.blank?
    end
    
    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
end
