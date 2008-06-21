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
    @contact_types = {'General Contact' => :general, 'Bug Report' => :bug, 'Feature Request' => :feature}
  end
  
  # Send the contact submission
  def send_contact_submission
    @contact = Contact.new(params[:contact])
    if @contact.save
      begin
        ContactMailer.deliver_basic(@contact)
        if @contact.contact_type == 'bug'
          ContactMailer.deliver_bug_report(@contact)
        elsif @contact.contact_type == 'feature'
          ContactMailer.deliver_ticket_creation(@contact)
        end
        flash[:notice] = "Thank you for contacting us"
        redirect_to :action => :contact
      rescue
        flash[:error] = "Sorry, something wen't wrong when sending your message. Our developers have been notified."
        redirect_to :action => :contact
      end
    else
      @contact_types = {'General Contact' => :general, 'Bug Report' => :bug, 'Feature Request' => :feature}
      render :action => :contact
    end
  end

  # Display the about page
  def about
  end

  def enquiries
    
  end
  
  def domestic_installations
    
  end
  
  def commercial_installations
    
  end
  
  def specialist_installations
    
  end
  
  def window_box_units
    
  end
  
  def floor_standing_tower_type
    
  end
  
  def free_hot_water_waste_heat
    
  end
  
  def maintenance_contracts
    
  end
  
  def services_and_breakdown
    
  end
  
  def hire_contracts
    
  end
  
  def unit_specifications
    
  end
  
end
