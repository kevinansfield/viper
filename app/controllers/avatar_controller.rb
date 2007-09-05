class AvatarController < ApplicationController
  
  before_filter :login_required, :protect_avatar
  
  def edit
    @user = User.find(params[:user_id])
    @avatar = @user.avatar || Avatar.new
  end
  
  def update
    @user = User.find(params[:user_id])
    @avatar = @user.avatar || Avatar.new(params[:avatar])
    @avatar.user = @user
    if @avatar.save
      flash[:notice] = 'Avatar was successfully saved'
      redirect_to hub_url
    else
      render :action => :edit
    end
  end
  
  private
  
  def protect_avatar
    @user = User.find(params[:user_id])
    unless @user == current_user
      flash[:error] = "That isn't your avatar!"
      redirect_to hub_url
      return false
    end
  end
  
end
