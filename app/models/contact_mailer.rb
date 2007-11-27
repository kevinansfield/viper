class ContactMailer < ActionMailer::Base
  
  helper :application
   
  def basic(contact)
    @recipients = VIPER_EMAIL
    @from = contact.email_address
    @subject = "#{SITENAME} Contact Form Submission"
    @body['name'] = contact.name
    @body['company'] = contact.company
    @body['phone'] = contact.phone
    @body['email'] = contact.email_address
    @body['contact_type'] = contact.contact_type
    @body['subject'] = contact.subject
    @body['message'] = contact.message
  end
  
  def ticket_creation(contact)
    @recipients = LIGHTHOUSE_EMAIL
    @from = LIGHTHOUSE_DEV
    @body['subject'] = contact.subject
    @body['message'] = contact.message
  end
end
