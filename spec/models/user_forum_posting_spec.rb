require File.dirname(__FILE__) + '/../spec_helper'

module ForumTopicCreateForumPostHelper
  def self.included(base)
    base.define_models
    
    base.before do
      @user  = users(:default)
      @attributes = {:body => 'booya'}
      @creating_topic = lambda { post! }
    end
  
    base.it "sets topic's last_updated_at" do
      @topic = post!
      @topic.should_not be_new_record
      @topic.reload.last_updated_at.should == @topic.posts.first.created_at
    end
  
    base.it "sets topic's last_user_id" do
      @topic = post!
      @topic.should_not be_new_record
      @topic.reload.last_user.should == @topic.posts.first.user
    end

    base.it "increments Topic.count" do
      @creating_topic.should change { ForumTopic.count }.by(1)
    end
    
    base.it "increments Post.count" do
      @creating_topic.should change { ForumPost.count }.by(1)
    end
    
    base.it "increments cached forum topics_count" do
      @creating_topic.should change { forums(:default).reload.topics_count }.by(1)
    end
    
    base.it "increments cached forum posts_count" do
      @creating_topic.should change { forums(:default).reload.posts_count }.by(1)
    end
    
    base.it "increments cached user posts_count" do
      @creating_topic.should change { users(:default).reload.forum_posts_count }.by(1)
    end
  end

  def post!
    @user.post_to_forum forums(:default), new_forum_topic(:default, @attributes).attributes
  end
end

describe User, "#post for users" do  
  include ForumTopicCreateForumPostHelper
  
  it "ignores sticky bit" do
    @attributes[:sticky] = 1
    @topic = post!
    @topic.should_not be_sticky
  end
  
  it "ignores locked bit" do
    @attributes[:locked] = true
    @topic = post!
    @topic.should_not be_locked
  end
end

describe User, "#post for moderators" do
  include ForumTopicCreateForumPostHelper
  
  before do
    @user.stub!(:moderator_of?).and_return(true)
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    @topic = post!
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    @topic = post!
    @topic.should be_locked
  end
end

describe User, "#post for admins" do
  include ForumTopicCreateForumPostHelper
  
  before do
    @user.stub!(:admin?).and_return(true)
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    @topic = post!
    @topic.should_not be_new_record
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    @topic = post!
    @topic.should_not be_new_record
    @topic.should be_locked
  end
end

module ForumTopicUpdateForumPostHelper
  def self.included(base)
    base.define_models
    
    base.before do
      @user  = users(:default)
      @topic = forum_topics(:default)
      @attributes = {:body => 'booya'}
    end
  end
  
  def revise!
    @user.revise @topic, @attributes
  end
end

describe User, "#revise(topic) for users" do  
  include ForumTopicUpdateForumPostHelper
  
  it "ignores sticky bit" do
    @attributes[:sticky] = 1
    revise!
    @topic.should_not be_sticky
  end
  
  it "ignores locked bit" do
    @attributes[:locked] = true
    revise!
    @topic.should_not be_locked
  end
end

describe User, "#revise(topic) for moderators" do
  include ForumTopicUpdateForumPostHelper
  
  before do
    @user.stub!(:moderator_of?).and_return(true)
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    revise!
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    revise!
    @topic.should be_locked
  end
end

describe User, "#revise(topic) for admins" do
  include ForumTopicUpdateForumPostHelper
  
  before do
    @user.stub!(:admin?).and_return(true)
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    revise!
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    revise!
    @topic.should be_locked
  end
end

describe User, "#reply_to_forum_topic" do
  define_models
  
  before do
    @user  = users(:default)
    @topic = forum_topics(:default)
    @creating_post = lambda { post! }
  end
  
  it "doesn't post if topic is locked" do
    @topic.locked = true; @topic.save
    @post = post!
    @post.should be_new_record
  end

  it "sets topic's last_updated_at" do
    @post = post!
    @topic.reload.last_updated_at.should == @post.created_at
  end

  it "sets topic's last_user_id" do
    ForumTopic.update_all 'last_user_id = 3'
    @post = post!
    @topic.reload.last_user.should == @post.user
  end
  
  it "increments Post.count" do
    @creating_post.should change { ForumPost.count }.by(1)
  end
  
  it "increments cached topic posts_count" do
    @creating_post.should change { forum_topics(:default).reload.posts_count }.by(1)
  end
  
  it "increments cached forum posts_count" do
    @creating_post.should change { forums(:default).reload.posts_count }.by(1)
  end

  def post!
    @user.reply_to_forum_topic forum_topics(:default), 'duane, i think you might be color blind.'
  end
end