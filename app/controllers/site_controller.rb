class SiteController < ApplicationController
  
  tab :home, :only => :index
  tab :contact, :only => [:contact, :send_contact_submission]
  tab :about, :only => :about
  
  # Display the homepage
  def index
  end

  # Display the contact page
  def contact
    @contact = Contact.new
  end
  
  # Send the contact submission
  def send_contact_submission
    @contact = Contact.new(params[:contact])
    if @contact.save
      begin
        ContactMailer::deliver_contact_message(@contact)
        flash[:notice] = "Thank you for contacting us"
        redirect_to :action => :contact
      rescue
        flash[:error] = "Sorry, something wen't wrong when sending your message. Our developers have been notified."
        redirect_to :action => :contact
      end
    else
      render :action => :contact
    end
  end

  # Display the about page
  def about
  end
  
end
