require File.dirname(__FILE__) + '/../test_helper'
require 'bio_controller'

# Re-raise errors caught by the controller.
class BioController; def rescue_action(e) raise e end; end

class BioControllerTest < Test::Unit::TestCase
  def setup
    @controller = BioController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
