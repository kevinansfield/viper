require File.dirname(__FILE__) + '/../test_helper'
require 'community_controller'

# Re-raise errors caught by the controller.
class CommunityController; def rescue_action(e) raise e end; end

class CommunityControllerTest < Test::Unit::TestCase
  def setup
    @controller = CommunityController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
