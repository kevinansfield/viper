require File.dirname(__FILE__) + '/../test_helper'
require 'news_controller'

# Re-raise errors caught by the controller.
class NewsController; def rescue_action(e) raise e end; end

class NewsControllerTest < Test::Unit::TestCase
  fixtures :news

  def setup
    @controller = NewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:news)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_news
    old_count = News.count
    post :create, :news => { }
    assert_equal old_count+1, News.count
    
    assert_redirected_to news_path(assigns(:news))
  end

  def test_should_show_news
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_news
    put :update, :id => 1, :news => { }
    assert_redirected_to news_path(assigns(:news))
  end
  
  def test_should_destroy_news
    old_count = News.count
    delete :destroy, :id => 1
    assert_equal old_count-1, News.count
    
    assert_redirected_to news_path
  end
end
