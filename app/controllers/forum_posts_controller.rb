class ForumPostsController < ApplicationController
  before_filter :find_parents
  before_filter :find_post, :only => [:edit, :update, :destroy]
  before_filter :setup_display
  
  tab :forums
  
  # /posts
  # /users/1/posts
  # /forums/1/posts
  # /forums/1/topics/1/posts
  def index
    @posts = (@parent ? @parent.posts : ForumPost).search(params[:q], :page => current_page)
    @users = @user ? {@user.id => @user} : User.index_from(@posts)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @posts }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
      format.xml  do
        find_post
        render :xml  => @post
      end
    end
  end

  def new
    @post = ForumPost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  def create
    @post = current_user.reply_to_forum_topic @topic, params[:post][:body]

    respond_to do |format|
      if @post.new_record?
        format.html { render :action => "new" }
        format.xml  { render :xml  => @post.errors, :status => :unprocessable_entity }
      else
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to(forum_topic_post_path(@forum, @topic, @post, :anchor => dom_id(@post))) }
        format.xml  { render :xml  => @post, :status => :created, :location => forum_topic_post_url(@forum, @topic, @post) }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to(forum_topic_path(@forum, @topic, :anchor => dom_id(@post))) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    path = @post.topic.reload.nil? ? forum_path(@post.forum) : forum_topic_path(@forum, @topic)
    flash[:notice] = "Forum post/topic deleted successfully"
    respond_to do |format|
      format.html { redirect_to(path) }
      format.xml  { head :ok }
    end
  end
  
protected
  def find_parents
    if params[:user_id]
      @parent = @user = User.find_by_permalink(params[:user_id])
    elsif params[:forum_id]
      @parent = @forum = Forum.find_by_permalink(params[:forum_id])
      @parent = @topic = @forum.topics.find_by_permalink(params[:topic_id]) if params[:topic_id]
    end
  end
  
  def find_post
    @post = @topic.posts.find(params[:id])
  end
  
  def setup_display
    self.sidebar_one = nil
    self.disable_maincols
  end
end
