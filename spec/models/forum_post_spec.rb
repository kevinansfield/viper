require File.dirname(__FILE__) + '/../spec_helper'

describe ForumPost do
  define_models
  
  it "finds topic" do
    forum_posts(:default).topic.should == forum_topics(:default)
  end
  
  it "requires body" do
    p = new_forum_post(:default)
    p.body = nil
    p.should_not be_valid
    p.errors.on(:body).should_not be_nil
  end

  it "formats body with textile" do
    f = ForumPost.new :body     => '*Bold*'
    f.body.should        == '<p><strong>Bold</strong></p>'
    f.body_plain.should  == 'Bold'
    f.body_source.should == '*Bold*'
  end
end

describe ForumPost, "being deleted" do
  define_models do
    model ForumPost do
      stub :second, :body => 'second', :created_at => current_time - 6.days
    end
  end
  
  before do
    @deleting_post = lambda { forum_posts(:default).destroy }
  end

  it "decrements cached forum posts_count" do
    @deleting_post.should change { forums(:default).reload.posts_count }.by(-1)
  end
  
  it "decrements cached user posts_count" do
    @deleting_post.should change { users(:default).reload.forum_posts_count }.by(-1)
  end

  it "fixes last_user_id" do
    forum_topics(:default).last_user_id = 1; forum_topics(:default).save
    forum_posts(:default).destroy
    forum_topics(:default).reload.last_user.should == users(:default)
  end
  
  it "fixes last_updated_at" do
    forum_posts(:default).destroy
    forum_topics(:default).reload.last_updated_at.should == forum_posts(:second).created_at
  end
  
  it "fixes #last_post" do
    forum_topics(:default).recent_post.should == forum_posts(:default)
    forum_posts(:default).destroy
    forum_topics(:default).recent_post(true).should == forum_posts(:second)
  end
end

describe ForumPost, "being deleted as sole post in topic" do
  define_models
  
  it "clears topic" do
    forum_posts(:default).destroy
    lambda { forum_topics(:default).reload }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe ForumPost, "#editable_by?" do
  before do
    @user  = mock_model User
    @post  = ForumPost.new :forum => @forum
    @forum = mock_model Forum, :user_id => @user.id
  end

  it "restricts user for other post" do
    @user.should_receive(:moderator_of?).and_return(false)
    @post.should_not be_editable_by(@user)
  end

  it "allows user" do
    @post.user_id = @user.id
    @post.should be_editable_by(@user)
  end
  
  it "allows admin" do
    @user.should_receive(:moderator_of?).and_return(true)
    @post.should be_editable_by(@user)
  end
  
  it "restricts moderator for other forum" do
    @post.should_receive(:forum).and_return @forum
    @user.should_receive(:moderator_of?).with(@forum).and_return(false)
    @post.should_not be_editable_by(@user)
  end
  
  it "allows moderator" do
    @post.should_receive(:forum).and_return @forum
    @user.should_receive(:moderator_of?).with(@forum).and_return(true)
    @post.should be_editable_by(@user)
  end
end