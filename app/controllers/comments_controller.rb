class CommentsController < ApplicationController
  before_filter :load_parent
  
  tab :blogs
  
  def new
    @comment = Comment.new
  end
  
  def create
    @comment = @parent.comments.build(params[:comment])
    @comment.user = current_user
  
    respond_to do |format|
      if @comment.valid? and @comment.save
        format.html { redirect_to post_path(@post) }
        format.js # create.rjs
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