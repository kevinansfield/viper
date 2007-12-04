class UsersController < ApplicationController
  
  before_filter :login_required, :only => [:hub, :edit, :change_email, :change_password, :invite, :send_invite]
  before_filter :protect_user, :only => [:edit, :change_email, :change_password, :invite, :send_invite]
  before_filter :check_logged_in, :only => [:new, :create, :activate]
  
  tab :hub
  tab :community, :only => :show
  tab :register, :only => :new
  tab :articles, :only => :articles
  
  # Display users list/search
  def index
    @users = User.find(:all)
  end
  
  # Display the user's hub
  def hub
    self.sidebar_one = 'sidebar_hub'
    self.maincol_one = 'blogs/maincol_blog'
    self.maincol_two = 'maincol_inbox'
    @user = current_user
    @user.setup_for_display!
    @posts = @user.blog.posts.paginate :page => params[:page]
  end
  
  # Display the user's public profile
  def show
    self.sidebar_one = 'sidebar_show'
    self.maincol_one = nil
    self.maincol_two = nil
    @user = User.find_by_permalink(params[:id])
    if @user.nil? and @user = User.find(params[:id])
      redirect_to user_url(@user)
    end
    @user.setup_for_display!
    @posts = @user.blog.posts.paginate :page => params[:page]
    unless @user == current_user
      @user.hit!
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Sorry, that user does not exist!"
    redirect_to '/'
  end

  # render new.rhtml
  def new
  end
  
  def edit
    @user = self.current_user
  end
  
  def change_email
    @user = self.current_user
    unless params[:user][:email].blank?
      @user.change_email_address(params[:user][:email])
      if @user.save
        @email_changed = true
        redirect_to edit_user_path, :id => @user
        return
      end
    else
      flash[:error] = "Please enter an email address"
    end
    @changing_email = true
    render :action => 'edit'
  end
  
  def change_password
    @user = self.current_user
    if @user.authenticated? params[:current_password]
      unless params[:user][:password].blank?
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        if @user.save
          @password_changed = true
          flash[:notice] = "Your password has been changed"
          redirect_to edit_user_path, :id => @user
          return
        end
      else
        flash[:error] = "New password cannot be blank"
      end
    else
      flash[:error] = "Sorry the current password was incorrect"
    end
    @changing_password = true
    render :action => 'edit'
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    # uncomment below if user should be automatically logged in
    #self.current_user = @user
    redirect_to '/'
    flash[:notice] = "Thanks for signing up! Please check your e-mail to activate your account."
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code]) 
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Signup complete! You may now use your account"
    end
    redirect_to login_url
  end
  
  def activate_new_email
    flash.clear  
    return unless params[:id].nil? or params[:email_activation_code].nil?
    activator = params[:id] || params[:email_activation_code]
    @user = User.find_by_email_activation_code(activator) 
    if @user and @user.activate_new_email
      redirect_to hub_url
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
  
  def invite
    @invite = Invite.new
  end
  
  def send_invite
    @invite = Invite.new(params[:invite])
    @invite.user = @user
    if @invite.save
      @invite.send_invites
      flash[:notice] = "Invite's have been sent"
      redirect_to hub_url
    else
      render :action => :invite
    end
  end
  
  def articles
    self.disable_maincols
    self.sidebar_one = 'sidebar_show'
    @user = User.find_by_permalink(params[:id])
    @articles = @user.articles
  end
  
  private
  
  def protect_user
    @user = User.find_by_permalink(params[:id])
    unless @user == current_user
      flash[:error] = "That isn't your user!"
      redirect_to hub_url
      return false
    end    
  end
  
  def check_logged_in
    unless @user.nil?
      flash[:error] = "Sorry, you already have a user account!"
      redirect_to hub_url
      return false
    end
  end

end
