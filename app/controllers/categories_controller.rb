class CategoriesController < ApplicationController
  
  tab :articles
  
  def index
    self.disable_maincols
    self.sidebar_one = 'categories/sidebar'
    @categories = Category.find(:all)
    @articles = Article.find_latest(30)
  end
  
  def new
    @category = Category.new
  end
  
  def show
    self.disable_maincols
    self.sidebar_one = nil
    @category = Category.find(params[:id])
    @latest_articles = @category.articles.find_latest
    @archive_articles = @category.articles.find_archive

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @category.to_xml }
    end
  end
  
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        format.html { redirect_to category_url(@category) }
        format.xml  { head :created, :location => category_url(@category) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors.to_xml }
      end
    end
  end
  
end
