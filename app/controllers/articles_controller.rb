class ArticlesController < ApplicationController
  
  tab :articles
  
  def index
    self.maincol_one = nil
    self.maincol_two = nil
    self.sidebar_one = nil
  end
  
end
