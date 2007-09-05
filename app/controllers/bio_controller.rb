class BioController < ApplicationController
  
  # GET /user/1/bio;edit
  def edit
    @user = User.find(params[:user_id])
    @bio = @user.bio || Bio.new
  end

  # PUT /user/1/bio
  # PUT /user/1/bio.xml
  def update
    @user = User.find(params[:user_id])
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
end
