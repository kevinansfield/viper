# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_jobs_session_id'
  
  # Default class variables
  class_inheritable_accessor :sidebar_one
  class_inheritable_accessor :sidebar_two
    
  self.sidebar_one = "layouts/sidebar_one"
  self.sidebar_two = "layouts/sidebar_two"
  
  # Return true if a parameter corresponding to the given symbol was posted.
  def param_posted?(symbol)
    request.post? and params[symbol]
  end
end
