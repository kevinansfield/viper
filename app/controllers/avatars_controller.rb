class AvatarsController < ApplicationController
  
  before_filter :login_required, :protect_avatar
  
  tab :hub
  
  def edit
    self.sidebar_one = nil
    self.disable_maincols
    @avatar = @user.avatar || Avatar.new
    
    unless @avatar.new_record?
      @small_avatar = @user.avatar.versions.find_by_version_name('small_square') || Avatar.new
      large = @avatar.versions.find_by_version_name('large')
      ratio = large.width.to_f / @avatar.width.to_f
      @crop_options = Avatar.calculate_crop_options(@small_avatar.crop_options, ratio)
    end
  end
  
  def update
    @avatar = Avatar.new(params[:avatar])
    if @avatar.save
      @user.avatar = @avatar
      @user.save
      flash[:notice] = 'Avatar was successfully uploaded'
      redirect_to edit_user_avatar_url(@user)
    else
      self.sidebar_one = nil
      self.disable_maincols
      render :action => :edit
    end
  end
  
  def crop
    avatar = @user.avatar.versions.find_by_version_name('small_square')
    Avatar.crop_all_versions!(avatar, params[:cropper])
    flash[:notice] = "Avatar successfully cropped"
    redirect_to edit_user_avatar_url(@user)
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
