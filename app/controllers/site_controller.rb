class SiteController < ApplicationController
  
  tab :home, :only => :index
  tab :contact, :only => :contact
  tab :about, :only => :about
  
  # Display the homepage
  def index
  end

  # Display the contact page
  def contact
  end

  # Display the about page
  def about
  end
  
end
