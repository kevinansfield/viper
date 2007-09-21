class PostsController < ApplicationController
  before_filter :find_blog
  before_filter :login_required, :protect_blog, :except => [:index, :show]
  
  # GET /posts
  # GET /posts.xml
  def index
    self.sidebar_one = 'posts/sidebar_blog'
    @posts = @blog.posts.paginate :page => params[:page]

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    self.sidebar_one = 'posts/sidebar_blog'
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @post.to_xml }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1;edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    @post.blog = @blog

    respond_to do |format|
      if @post.duplicate? or @blog.posts << @post
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to post_url(@post.blog, @post) }
        format.xml  { head :created, :location => post_url(:id => @post) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors.to_xml }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to post_url(:id => @post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors.to_xml }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def find_blog
    @blog = Blog.find(params[:blog_id])
  end
  
  def protect_blog
    @user == current_user
    unless @blog.user == current_user
      flash[:error] = "That isn't your blog!"
      redirect_to hub_url
      return false
    end    
  end
end
