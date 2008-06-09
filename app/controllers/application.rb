# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  # Set the theme here
  theme 'allfourseasons'
  
  helper :all # include all helpers, all the time
  
  helper_method :current_page
  
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
  
  # Count the number of sidebars specified
  def sidebar_count
    [self.sidebar_one, self.sidebar_two].compact.length
  end
  
  def maincol_count
    [self.maincol_one, self.maincol_two].compact.length
  end
  
  def disable_maincols
    self.maincol_one = nil
    self.maincol_two = nil
  end
  
  # Reset the partials (useful as it seems that controllers are carried over between requests)
  def reset_partials
    self.maincol_one = MAINCOL_ONE
    self.maincol_two = MAINCOL_TWO
    self.sidebar_one = SIDEBAR_ONE
    self.sidebar_two = SIDEBAR_TWO
  end
  
  # set current tab
  def self.tab(name, options = {})
    before_filter(options) do |controller|
      controller.instance_variable_set('@current_tab', name)
    end
  end
  
  # Return true if a parameter corresponding to the given symbol was posted.
  def param_posted?(symbol)
    request.post? and params[symbol]
  end
  
  def current_page
    @page ||= params[:page].blank? ? 1 : params[:page].to_i
  end
end
