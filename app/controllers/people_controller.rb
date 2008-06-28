class PeopleController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_person, :only => [:suspend, :unsuspend, :destroy, :purge]
  

  # render new.rhtml
  def new
    @person = Person.new
  end
 
  def create
    logout_keeping_session!
    @person = Person.new(params[:person])
    @person.register! if @person && @person.valid?
    success = @person && @person.valid?
    if success && @person.errors.empty?
            redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    person = Person.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && person && !person.active?
      person.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a person with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def suspend
    @person.suspend! 
    redirect_to people_path
  end

  def unsuspend
    @person.unsuspend! 
    redirect_to people_path
  end

  def destroy
    @person.delete!
    redirect_to people_path
  end

  def purge
    @person.destroy
    redirect_to people_path
  end
  
  # There's no page here to update or destroy a person.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_person
    @person = Person.find(params[:id])
  end
end
