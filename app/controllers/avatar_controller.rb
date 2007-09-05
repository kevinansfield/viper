class AvatarController < ApplicationController
  
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
  
end
