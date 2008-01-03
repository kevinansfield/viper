class CommentsController < ApplicationController
  before_filter :load_parent, :except => :index
  
  tab :blogs
  
  def index
    @approved_comments = Comment.recent(20, :approved => true)
    @rejected_comments = Comment.recent(100, :approved => false) if logged_in? && current_user.admin?
  end
  
  def new
    @comment = Comment.new
  end
  
  def create
    @comment = @parent.comments.build(params[:comment])
    @comment.user_id = current_user.id
    @comment.request = request
  
    respond_to do |format|
      if @comment.valid? and @comment.save
        if @comment.approved?
          format.html { redirect_to post_path(@post) }
          format.js # create.rjs
        else
          flash[:error] = "Sorry, your message was flagged as possible spam by Akismet. " +
                          "It will appear once approved by an administrator."
          redirect_to post_path(@post)
        end
      else
        format.html { redirect_to parent_url(@parent) }
        format.js { render :nothing => true }
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    user = current_user
  
    if @comment.authorized?(user, @parent)
      @comment.destroy
    else
      flash[:error] = "That's not your comment!"
      redirect_to hub_url
      return
    end
  
    respond_to do |format|
      format.js # destroy.js
    end
  end
  
  def destroy_multiple
    Comment.destroy(params[:comment_ids])
    flash[:notice] = "Successfully destroyed comments"
    redirect_to comments_path
  end
  
  def approve
    @comment = Comment.find(params[:comment_id])
    @comment.mark_as_ham!
    redirect_to comments_path
  end
  
  def reject
    @comment = Comment.find(params[:comment_id])
    @comment.mark_as_spam!
    redirect_to comments_path
  end
  
  private
  
  def load_parent
    case
      when params[:post_id] then @parent = Post.find(params[:post_id])
      when params[:wall_id] then @parent = Wall.find(params[:wall_id])
    end
  end
  
  def parent_url(parent)
    case
      when params[:post_id] then blog_post_url(parent)
      when params[:wall_id] then user_wall_url(parent)
    end
  end
  
end