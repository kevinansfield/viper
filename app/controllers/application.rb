# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  before_filter :reset_sidebars
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_jobs_session_id'
  
  # Default class variables
  class_inheritable_accessor :sidebar_one
  class_inheritable_accessor :sidebar_two
    
  @sidebar_one = SIDEBAR_ONE
  @sidebar_two = SIDEBAR_TWO
  
  # Reset the sidebars (useful as it seems that controllers are carried over between requests)
  def reset_sidebars
    self.sidebar_one = SIDEBAR_ONE
    self.sidebar_two = SIDEBAR_TWO
  end
  
  # Return true if a parameter corresponding to the given symbol was posted.
  def param_posted?(symbol)
    request.post? and params[symbol]
  end
end
