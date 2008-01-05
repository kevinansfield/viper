# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  tab :login

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    render :action => 'new' && return unless logged_in?
    
    set_remember_cookie if params[:remember_me] == "1"
    
    redirect_back_or_default('/')
    flash[:notice] = "#{self.current_user.first_name} logged in successfully"
    
  rescue AuthenticationException => e
    flash[:error] = e.message
    redirect_to login_path
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  private
  
    def set_remember_cookie
      self.current_user.remember_me
      cookies[:auth_token] = { 
        :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at
      }
    end
end
