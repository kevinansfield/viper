require File.dirname(__FILE__) + '/../test_helper'
require 'site_controller'

# Re-raise errors caught by the controller.
class SiteController; def rescue_action(e) raise e end; end

class SiteControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = SiteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template "index"
  end
  
  # Test the navigation menu helper
  def test_navigation_identifies_current_tab
    get :index
    assert_tag "li", :content => /Home/,
               :attributes => { :class => "active" }
  end
  
  # Test the navigation menu before login.
  def test_navigation_not_logged_in
    get :index
    assert_tag "a", :content => /Register/,
               :attributes => { :href => /\/signup/ }
    assert_tag "a", :content => /Login/,
               :attributes => { :href => /\/login/ }
  end
  
  # Test the navigation menu after login
  def test_navigation_logged_in
    login_as :quentin
    get :index
    assert_tag "a", :content => /Your Hub/,
               :attributes => { :href => "#" }
    assert_tag "a", :content => /Logout/,
               :attributes => { :href => /\/logout/ }
  end
end
