class UsersController < ApplicationController
  
  before_filter :login_required, :only => [:hub, :edit, :change_email]
  
  # Display users list/search
  def index
    @users = User.find(:all)
  end
  
  # Display the user's hub
  def hub
    self.sidebar_one = 'sidebar_hub'
  end

  # render new.rhtml
  def new
  end
  
  def edit
    @user = self.current_user
  end
  
  def change_email
    @user = self.current_user
    return unless request.post?
    unless params[:user][:email].blank?
      @user.change_email_address(params[:user][:email])
      if @user.save
        @changed = true
      end
    else
      flash[:error] = "Please enter an email address" 
    end
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up! Please check your e-mail to activate your account."
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Signup complete! You may now login."
    end
    redirect_back_or_default('/')
  end
  
  def activate_new_email
     flash.clear  
     return unless params[:id].nil? or params[:email_activation_code].nil?
     activator = params[:id] || params[:email_activation_code]
     @user = User.find_by_email_activation_code(activator) 
     if @user and @user.activate_new_email
       redirect_back_or_default(hub_url)
       flash[:notice] = "The email address for your account has been updated" 
     else
       flash[:error] = "Unable to update the email address" 
     end
   end
   
   def forgot_password
     return unless request.post?
     if @user = User.find_for_forgot(params[:email])
       @user.forgot_password
       @user.save
       redirect_to login_url
       flash[:notice] = "A password reset link has been sent to your email address" 
     else
       flash[:error] = "Could not find a user with that email address" 
     end
   end
   
   def reset_password
     @user = User.find_by_password_reset_code(params[:id])
     raise if @user.nil?
     return if @user unless params[:password]
       if (params[:password] == params[:password_confirmation])
         self.current_user = @user #for the next two lines to work
         current_user.password_confirmation = params[:password_confirmation]
         current_user.password = params[:password]
         @user.reset_password
         flash[:notice] = current_user.save ? "Password reset" : "Password not reset" 
       else
         flash[:error] = "Password mismatch" 
       end  
       redirect_back_or_default(hub_url) 
   rescue
     logger.error "Invalid Reset Code entered" 
     flash[:error] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)" 
     redirect_back_or_default(hub_url)
   end

end
