class BlogsController < ApplicationController
  
  tab :blogs
  
  def index
    self.maincol_one = nil
    self.maincol_two = nil
    self.sidebar_one = nil
    
    @posts = Post.find_latest_by_unique_authors(10)
  end
  
end