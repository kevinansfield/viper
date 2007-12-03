class BlogsController < ApplicationController
  
  tab :blogs
  
  def index
    self.maincol_one = nil
    self.maincol_two = nil
    self.sidebar_one = nil
    
    respond_to do |format|
      format.html do
        @posts = Post.find_latest_by_unique_authors(10)
      end
      format.rss do
        @posts = Post.find_latest(25)
        render :action => 'index.rxml', :layout => false
      end
    end
  end
  
  def show
    redirect_to blog_posts_url(params[:id])
  end
  
end