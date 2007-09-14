require File.dirname(__FILE__) + '/../test_helper'
require 'friendship_controller'

# Re-raise errors caught by the controller.
class FriendshipController; def rescue_action(e) raise e end; end

class FriendshipControllerTest < Test::Unit::TestCase
  def setup
    @controller = FriendshipController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
