class ProfileController < ApplicationController

  # GET /user/1/profile;edit
  def edit
    @user = User.find(params[:user_id])
    @profile = @user.profile || Profile.new
  end

  # PUT /user/1/profile
  # PUT /user/1/profile.xml
  def update
    @user = User.find(params[:user_id])
    @profile = @user.profile || Profile.new
    @profile.user = @user

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to hub_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors.to_xml }
      end
    end
  end

end
