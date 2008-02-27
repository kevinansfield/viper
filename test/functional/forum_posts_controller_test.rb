require File.dirname(__FILE__) + '/../test_helper'

class ForumPostsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:forum_posts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_forum_post
    assert_difference('ForumPost.count') do
      post :create, :forum_post => { }
    end

    assert_redirected_to forum_post_path(assigns(:forum_post))
  end

  def test_should_show_forum_post
    get :show, :id => forum_posts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => forum_posts(:one).id
    assert_response :success
  end

  def test_should_update_forum_post
    put :update, :id => forum_posts(:one).id, :forum_post => { }
    assert_redirected_to forum_post_path(assigns(:forum_post))
  end

  def test_should_destroy_forum_post
    assert_difference('ForumPost.count', -1) do
      delete :destroy, :id => forum_posts(:one).id
    end

    assert_redirected_to forum_posts_path
  end
end
