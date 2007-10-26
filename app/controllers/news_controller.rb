class NewsController < ApplicationController
  
  tab :news
  
  # GET /news
  # GET /news.xml
  def index
    @news = News.find(:all, :order => "created_at DESC")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @news.to_xml }
    end
  end

  # GET /news/1
  # GET /news/1.xml
  def show
    @news_item = News.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @news.to_xml }
    end
  end

  # GET /news/new
  def new
    @news = News.new
  end

  # GET /news/1;edit
  def edit
    @news = News.find(params[:id])
  end

  # POST /news
  # POST /news.xml
  def create
    @news = News.new(params[:news])
    @news.user = current_user
    @news.send_as_email if params[:send_as_email] == 'true'

    respond_to do |format|
      if @news.save
        flash[:notice] = 'News was successfully created.'
        format.html { redirect_to news_item_url(@news) }
        format.xml  { head :created, :location => news_url(@news) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news.errors.to_xml }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.xml
  def update
    @news = News.find(params[:id])

    respond_to do |format|
      if @news.update_attributes(params[:news])
        flash[:notice] = 'News was successfully updated.'
        format.html { redirect_to news_item_url(@news) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news.errors.to_xml }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.xml
  def destroy
    @news = News.find(params[:id])
    @news.destroy

    respond_to do |format|
      format.html { redirect_to news_url }
      format.xml  { head :ok }
    end
  end
end
