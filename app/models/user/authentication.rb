class User  
  def admin?
    current_state == :active && admin
  end
 
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    u = find :first, :conditions => {:login => login} # need to get the salt
    raise AuthenticationException.new("Sorry, we cannot find an account matching that login.") if u.nil?
    raise AuthenticationException.new("Oops, the password you entered does not match our records, please try again.") unless u.authenticated?(password)
    raise AuthenticationException.new("Sorry, you must activate your account before you can log in.") if u.current_state == :pending
    raise AuthenticationException.new("Sorry, this account has been suspended.") if u.current_state == :suspended
    raise AuthenticationException.new("Sorry, this account has been deleted.") if u.current_state == :deleted
    u && u.authenticated?(password) ? u : nil
  end

end