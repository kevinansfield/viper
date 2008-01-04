# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  tab :login

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in? && self.current_user.activation_code.nil?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "#{self.current_user.login} logged in successfully"
    elsif logged_in? && !self.current_user.activation_code.nil?
      flash[:error] = "Sorry, you will need to activate your account before continuing, please check your email for your activation code"
      @login = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    else
      flash[:error] = "Invalid username/password combination"
      @login = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
