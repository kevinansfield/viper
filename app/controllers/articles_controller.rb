class ArticlesController < ApplicationController
  
  tab :articles
  
  def index
    self.disable_maincols
    self.sidebar_one = nil
  end
  
  def show
    self.disable_maincols
    self.sidebar_one = nil
    @article = Article.find(params[:id])
  end
  
  def new
    self.disable_maincols
    self.sidebar_one = nil
    @article = Article.new
    @article.category_id = params[:category_id] if params[:category_id]
    @categories = Category.find(:all)
  end
  
  def edit
    self.disable_maincols
    self.sidebar_one = nil
    @article = Article.find(params[:id])
    @categories = Category.find(:all)
  end
  
  def create
    @article = Article.new(params[:article])
    @article.user = current_user

    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to category_url(@article.category) }
        format.xml  { head :created, :location => category_url(@article.category) }
      else
        self.disable_maincols
        self.sidebar_one = nil
        @categories = Category.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end
  
  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to article_url(:id => @article) }
        format.xml  { head :ok }
      else
        self.disable_maincols
        self.sidebar_one = nil
        @categories = Category.find(:all)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end
  
end
