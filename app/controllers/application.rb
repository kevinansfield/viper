# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  before_filter :reset_partials
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_jobs_session_id'
  
  # Default class variables
  class_inheritable_accessor :maincol_one
  class_inheritable_accessor :maincol_two
  class_inheritable_accessor :sidebar_one
  class_inheritable_accessor :sidebar_two
  
  @maincol_one = MAINCOL_ONE
  @maincol_two = MAINCOL_TWO
  @sidebar_one = SIDEBAR_ONE
  @sidebar_two = SIDEBAR_TWO
  
  # Reset the partials (useful as it seems that controllers are carried over between requests)
  def reset_partials
    self.maincol_one = MAINCOL_ONE
    self.maincol_two = MAINCOL_TWO
    self.sidebar_one = SIDEBAR_ONE
    self.sidebar_two = SIDEBAR_TWO
  end
  
  # Return true if a parameter corresponding to the given symbol was posted.
  def param_posted?(symbol)
    request.post? and params[symbol]
  end
end
