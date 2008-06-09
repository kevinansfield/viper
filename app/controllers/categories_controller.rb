class CategoriesController < ApplicationController
  before_filter :find_category, :except => [:new, :create]
  
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
  
  def edit
  end
  
  def show
    self.disable_maincols
    self.sidebar_one = 'categories/sidebar'
    @latest_articles = @category.articles.find_latest
    @archive_articles = @category.articles.find_archive
    @categories = Category.find(:all)

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
  
  def update
    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to category_url(@category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors.to_xml }
      end
    end
  end
  
  def destroy
    @category.destroy
    flash[:notice] = "Category '#{@category.name}' deleted"
    respond_to do |format|
      format.html { redirect_to categories_url }
      format.xml  { head :ok }
    end
  end
  
protected

  def find_category
    @category = Category.find_by_permalink(params[:id])
  end
  
end
