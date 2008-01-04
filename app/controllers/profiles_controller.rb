class ProfilesController < ApplicationController
  
  before_filter :login_required, :protect_profile
  
  tab :hub

  # GET /user/1/profile;edit
  def edit
    @user = User.find_by_permalink(params[:user_id])
    @profile = @user.profile || Profile.new
    blank_im_contacts = 3 - @profile.im_contacts.length
    blank_im_contacts.times { @profile.im_contacts.build }
  end

  # PUT /user/1/profile
  # PUT /user/1/profile.xml
  def update
    @user = User.find_by_permalink(params[:user_id])
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
  
  private
  
  def protect_profile
    @user = User.find_by_permalink(params[:user_id])
    unless @user == current_user
      flash[:error] = "That isn't your profile!"
      redirect_to hub_url
      return false
    end
  end

end
