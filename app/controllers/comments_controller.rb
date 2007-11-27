class CommentsController < ApplicationController
  before_filter :load_post
  
  tab :blogs
  
  def create
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @comment.post = @post
  
    respond_to do |format|
      if @comment.duplicate? or @post.comments << @comment
        format.html { redirect_to post_path(@post) }
        format.js # create.rjs
      else
        format.html { redirect_to new_comment_url(@post.blog, @post) }
        format.js { render :nothing => true }
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    user = current_user
  
    if @comment.authorized?(user)
      @comment.destroy
    else
      flash[:error] = "That's not your blog!"
      redirect_to hub_url
      return
    end
  
    respond_to do |format|
      format.js # destroy.js
    end
  end
  
  private
  
  def load_post
    @post = Post.find(params[:post_id])
  end
end