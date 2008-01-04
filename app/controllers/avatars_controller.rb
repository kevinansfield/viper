class AvatarsController < ApplicationController
  
  before_filter :login_required, :protect_avatar
  
  tab :hub
  
  def edit
    @avatar = @user.avatar || Avatar.new
  end
  
  def update
    @avatar = Avatar.new(params[:avatar])
    #@user.avatar = @avatar
    if @avatar.save
      @user.avatar = @avatar
      @user.save
      flash[:notice] = 'Avatar was successfully saved'
      redirect_to hub_url
    else
      render :action => :edit
    end
  end
  
  private
  
  def protect_avatar
    @user = User.find_by_permalink(params[:user_id])
    unless @user == current_user
      flash[:error] = "That isn't your avatar!"
      redirect_to hub_url
      return false
    end
  end
  
end
