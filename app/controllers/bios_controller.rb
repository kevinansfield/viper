class BiosController < ApplicationController
  
  before_filter :login_required, :protect_bio
  
  tab :hub, :only => :edit
  
  # GET /user/1/bio;edit
  def edit
    @bio = @user.bio || Bio.new
  end

  # PUT /user/1/bio
  # PUT /user/1/bio.xml
  def update
    @bio = @user.bio || Bio.new
    @bio.user = @user

    respond_to do |format|
      if @bio.update_attributes(params[:bio])
        flash[:notice] = 'Bio was successfully updated.'
        format.html { redirect_to hub_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bio.errors.to_xml }
      end
    end
  end
  
  private
  
  def protect_bio
    @user = User.find_by_permalink(params[:user_id])
    unless @user == current_user
      flash[:error] = "That isn't your bio!"
      redirect_to hub_url
      return false
    end
  end
end
